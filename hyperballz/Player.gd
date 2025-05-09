extends CharacterBody3D

@export var jump_strength = 5.0
@export var sprint_multiplier = 2.0
@onready var camera = $Camera3D
var base_speed = 5.0
var mouse_sensitivity = 0.005
var gravity = -9.8

func _ready():
	add_to_group("players")
	if is_multiplayer_authority():
		camera.current = true
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if is_multiplayer_authority() and event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)
		camera.rotate_x(-event.relative.y * mouse_sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)

func _physics_process(delta):
	if is_multiplayer_authority():
		var input_vector = Vector2(
			Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
			Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")
		).normalized()

		# Calculate current speed based on sprint input
		var move_speed = base_speed
		if Input.is_action_pressed("sprint"):
			move_speed *= sprint_multiplier

		# Calculate movement direction based on input and orientation
		var move_direction = Vector3(input_vector.x, 0, input_vector.y) * move_speed
		move_direction = global_transform.basis * move_direction

		# Update horizontal velocity
		velocity.x = move_direction.x
		velocity.z = move_direction.z

		# Handle jumping
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = jump_strength

		# Apply gravity
		velocity.y += gravity * delta

		# Apply movement
		move_and_slide()

		if Input.is_action_just_pressed("throw"):
			throw_ball.rpc()

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
