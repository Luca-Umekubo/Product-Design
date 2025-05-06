extends CharacterBody3D

@export var speed: float = 5.0
@export var sensitivity: float = 0.1
@export var throw_speed: float = 10.0

@onready var camera: Camera3D = $Camera3D
@onready var ball_spawn_point: Node3D = $Camera3D/BallSpawnPoint
@onready var synchronizer: MultiplayerSynchronizer = $PlayerSynchronizer

func _ready():
	if is_multiplayer_authority():
		camera.current = true
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		synchronizer.set_multiplayer_authority(get_multiplayer_authority())

func _input(event):
	if not is_multiplayer_authority():
		return
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * sensitivity))
		var cam_rot = camera.rotation_degrees.x - event.relative.y * sensitivity
		camera.rotation_degrees.x = clamp(cam_rot, -90, 90)
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var position = ball_spawn_point.global_position
		var direction = -camera.global_transform.basis.z
		var velocity = direction * throw_speed
		get_tree().root.get_node("Main").rpc_id(1, "request_spawn_ball", position, velocity)

func _physics_process(delta):
	if not is_multiplayer_authority():
		return
	
	# Movement
	var input_dir = Vector3.ZERO
	if Input.is_action_pressed("ui_up"):
		input_dir.z -= 1
	if Input.is_action_pressed("ui_down"):
		input_dir.z += 1
	if Input.is_action_pressed("ui_left"):
		input_dir.x -= 1
	if Input.is_action_pressed("ui_right"):
		input_dir.x += 1
	if input_dir.length() > 1:
		input_dir = input_dir.normalized()
	
	var horizontal_velocity = global_transform.basis * input_dir * speed
	velocity.x = horizontal_velocity.x
	velocity.z = horizontal_velocity.z
	
	# Gravity
	if not is_on_floor():
		velocity.y -= 9.8 * delta
	else:
		velocity.y = 0
	
	move_and_slide()
