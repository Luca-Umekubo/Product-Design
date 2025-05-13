extends CharacterBody3D

@onready var camera = $Camera3D
var speed = 5.0
var mouse_sensitivity = 0.005
var gravity = -9.8
var is_spectator = false  # Tracks spectator mode status
var hit_material = null

func _ready():
	add_to_group("players")
	
	# Try to load the hit material if it exists
	if ResourceLoader.exists("res://hit_material.tres"):
		hit_material = load("res://hit_material.tres")
	
	if multiplayer.has_multiplayer_peer() and is_multiplayer_authority():
		camera.current = true
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event):
	if multiplayer.has_multiplayer_peer() and is_multiplayer_authority() and event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)
		camera.rotate_x(-event.relative.y * mouse_sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)
	
	# Prevent throwing balls in spectator mode
	if is_spectator:
		return
	if event.is_action_pressed("throw"):
		throw_ball.rpc()

func _physics_process(delta):
	if multiplayer.has_multiplayer_peer() and is_multiplayer_authority():
		if is_spectator:
			# Flying movement for spectator mode
			var input_vector = Vector3(
				Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
				Input.get_action_strength("jump") - Input.get_action_strength("crouch"),
				Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")
			).normalized()
			
			# Apply movement relative to camera direction
			var move_direction = (camera.global_transform.basis * input_vector).normalized() * speed * 2.0
			velocity = move_direction
			move_and_slide()
		else:
			# Normal player movement
			var input_vector = Vector2(
				Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
				Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward") 
			).normalized()

			var move_direction = Vector3(input_vector.x, 0, input_vector.y) * speed
			move_direction = global_transform.basis * move_direction
			
			velocity.x = move_direction.x
			velocity.z = move_direction.z
			velocity.y += gravity * delta
			
			move_and_slide()
			
			# Handle pushing balls
			for i in range(get_slide_collision_count()):
				var collision = get_slide_collision(i)
				if collision.get_collider() is RigidBody3D and collision.get_collider().is_in_group("balls"):
					var push_strength = 2.5
					if velocity.length() > 0.1:
						collision.get_collider().apply_central_impulse(-collision.get_normal() * push_strength * velocity.length())
					else:
						if input_vector.length() > 0.1:
							var push_direction = global_transform.basis * Vector3(input_vector.x, 0, input_vector.y).normalized()
							collision.get_collider().apply_central_impulse(push_direction * push_strength)

@rpc("any_peer", "call_local")
func throw_ball():
	if not multiplayer.is_server():
		return
		
	var spawn_direction = -$Camera3D.global_transform.basis.z.normalized()
	var spawn_distance = 1.5
	var spawn_position = $Camera3D/BallSpawnPoint.global_position + (spawn_direction * spawn_distance)
	
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(
		$Camera3D.global_position,
		spawn_position
	)
	query.exclude = [self]
	var result = space_state.intersect_ray(query)
	
	if result:
		spawn_position = result.position - (spawn_direction * 0.3)
	
	var spawn_velocity = spawn_direction * 10
	var ball_data = {
		"position": spawn_position,
		"velocity": spawn_velocity
	}
	get_tree().get_root().get_node("Game/Balls/BallSpawner").spawn(ball_data)

@rpc("call_local")
func update_lives(new_lives):
	# Update lives locally; actual tracking is done on server
	if multiplayer.has_multiplayer_peer() and is_multiplayer_authority():
		if hit_material != null and new_lives > 0:
			$MeshInstance3D.material_override = hit_material
			var timer = get_tree().create_timer(0.3)
			timer.timeout.connect(func(): $MeshInstance3D.material_override = null)
		print("Player ", name, " lives: ", new_lives)

@rpc("call_local")
func set_spectator_mode():
	if multiplayer.has_multiplayer_peer() and is_multiplayer_authority():
		is_spectator = true
		# Disable collisions
		collision_layer = 0
		collision_mask = 0
		# Hide player model
		$MeshInstance3D.visible = false
		# Ensure camera remains active
		camera.current = true
		print("Player ", name, " entered spectator mode")

@rpc("call_local")
func respawn():
	if multiplayer.has_multiplayer_peer() and is_multiplayer_authority():
		var spawn_points = get_tree().get_nodes_in_group("spawn_points")
		if spawn_points.size() > 0:
			var spawn_point = spawn_points[randi() % spawn_points.size()]
			position = spawn_point.global_position
		# Reset collision and visibility
		collision_layer = 1  # Restore default player layer
		collision_mask = 2 | 3  # Collide with balls and environment
		$MeshInstance3D.visible = true
		is_spectator = false
		print("Player ", name, " respawned")
