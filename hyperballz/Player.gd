extends CharacterBody3D

@onready var camera = $Camera3D
var speed = 5.0
var mouse_sensitivity = 0.005
var gravity = -9.8
var lives = 2  # Player starts with 2 lives

# Optional reference to a hit material for visual feedback
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

func _physics_process(delta):
	if multiplayer.has_multiplayer_peer() and is_multiplayer_authority():
		var input_vector = Vector2(
			Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
			Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward") 
		).normalized()

		# Calculate movement direction based on input and orientation
		var move_direction = Vector3(input_vector.x, 0, input_vector.y) * speed
		move_direction = global_transform.basis * move_direction
		
		# Update velocity components directly
		velocity.x = move_direction.x
		velocity.z = move_direction.z
		velocity.y += gravity * delta
		
		# Apply movement
		move_and_slide()
		
		# Handle pushing balls - Godot 4.4.1 syntax
		for i in range(get_slide_collision_count()):
			var collision = get_slide_collision(i)
			if collision.get_collider() is RigidBody3D and collision.get_collider().is_in_group("balls"):
				var push_strength = 2.5
				# Only push if we're actually moving
				if velocity.length() > 0.1:
					collision.get_collider().apply_central_impulse(-collision.get_normal() * push_strength * velocity.length())
				else:
					# Even when not moving but trying to push
					if input_vector.length() > 0.1:
						var push_direction = global_transform.basis * Vector3(input_vector.x, 0, input_vector.y).normalized()
						collision.get_collider().apply_central_impulse(push_direction * push_strength)

		if Input.is_action_just_pressed("throw"):
			throw_ball.rpc()

@rpc("any_peer", "call_local")
func throw_ball():
	if not multiplayer.is_server():
		return
		
	# Get spawn position further away from player to avoid collision
	var spawn_direction = -$Camera3D.global_transform.basis.z.normalized()
	var spawn_distance = 1.5  # Increased distance to avoid collision with player
	var spawn_position = $Camera3D/BallSpawnPoint.global_position + (spawn_direction * spawn_distance)
	
	# Check if spawn position is valid (not inside another object)
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(
		$Camera3D.global_position,
		spawn_position
	)
	query.exclude = [self]  # Exclude the player from the check
	var result = space_state.intersect_ray(query)
	
	# If the ray hits something, adjust spawn position to be in front of that object
	if result:
		# Place the ball just before the collision point
		spawn_position = result.position - (spawn_direction * 0.3)
	
	var spawn_velocity = spawn_direction * 10  # Speed of 10
	var ball_data = {
		"position": spawn_position,
		"velocity": spawn_velocity
	}
	get_tree().get_root().get_node("Game/Balls/BallSpawner").spawn(ball_data)

@rpc("authority")
func hit_by_ball():
	if multiplayer.has_multiplayer_peer() and is_multiplayer_authority():
		lives -= 1
		update_lives.rpc(lives)
		
		if lives <= 0:
			# No lives left, respawn the player
			respawn()
		else:
			# Still has lives, just show visual feedback
			if hit_material != null:
				$MeshInstance3D.material_override = hit_material
				# Using a timer node since await might not work reliably in networked context
				var timer = get_tree().create_timer(0.3)
				timer.timeout.connect(func(): $MeshInstance3D.material_override = null)

@rpc("authority", "call_local")
func update_lives(new_lives):
	lives = new_lives
	# You can update UI here if you have one
	print("Player ", name, " lives: ", lives)

@rpc("authority")
func respawn():
	if multiplayer.has_multiplayer_peer() and is_multiplayer_authority():
		# Reset lives on respawn
		lives = 2
		update_lives.rpc(lives)
		
		var spawn_points = get_tree().get_nodes_in_group("spawn_points")
		if spawn_points.size() > 0:
			var spawn_point = spawn_points[randi() % spawn_points.size()]
			position = spawn_point.global_position
