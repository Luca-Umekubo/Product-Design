extends CharacterBody3D

@onready var camera = $Camera3D
var speed = 5.0
var mouse_sensitivity = 0.005
var gravity = -9.8

func _ready():
	add_to_group("players")
	if is_multiplayer_authority():
		camera.current = true
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if is_multiplayer_authority() and event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		camera.rotate_x(-event.relative.y * mouse_sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)

func _physics_process(delta):
	if is_multiplayer_authority():
		# Always apply gravity
		velocity.y += gravity * delta
		
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			var input_vector = Vector2(
				Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
				Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")
			).normalized()

			# Calculate movement direction based on input and orientation
			var move_direction = Vector3(input_vector.x, 0, input_vector.y) * speed
			move_direction = global_transform.basis * move_direction
			
			# Update horizontal velocity
			velocity.x = move_direction.x
			velocity.z = move_direction.z
			
			if Input.is_action_just_pressed("throw"):
				throw_ball.rpc()
		else:
			# When mouse is not captured, stop horizontal movement
			velocity.x = 0
			velocity.z = 0
		
		# Apply movement
		move_and_slide()

@rpc("any_peer", "call_local")
func throw_ball():
	if not multiplayer.is_server():
		return
	var spawn_position = $Camera3D/BallSpawnPoint.global_position
	var spawn_velocity = $Camera3D.global_transform.basis.z * -10
	var ball_data = {
		"position": spawn_position,
		"velocity": spawn_velocity
	}
	get_tree().get_root().get_node("Game/Balls/BallSpawner").spawn(ball_data)

@rpc("authority")
func respawn():
	if is_multiplayer_authority():
		var spawn_points = get_tree().get_nodes_in_group("spawn_points")
		if spawn_points.size() > 0:
			var spawn_point = spawn_points[randi() % spawn_points.size()]
			position = spawn_point.global_position
