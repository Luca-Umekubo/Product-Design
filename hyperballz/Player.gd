extends CharacterBody3D

@export var sensitivity: float = 0.1
@export var speed: float = 5.0
@export var throw_speed: float = 10.0

@onready var camera = $Camera3D
@onready var ball_spawn_point = $Camera3D/BallSpawnPoint

var puppet_transform: Transform3D

func _ready():
	if is_multiplayer_authority():
		camera.current = true
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event):
	if is_multiplayer_authority():
		if event is InputEventMouseMotion:
			var mouse_delta = event.relative
			rotate_y(deg_to_rad(-mouse_delta.x * sensitivity))
			var cam_rot = camera.rotation_degrees.x - mouse_delta.y * sensitivity
			cam_rot = clamp(cam_rot, -90, 90)
			camera.rotation_degrees.x = cam_rot
		elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			var position = ball_spawn_point.global_position
			var direction = -camera.global_transform.basis.z
			var velocity = direction * throw_speed
			get_parent().rpc_id(1, "request_spawn_ball", position, velocity) # Call RPC on Main node

func _physics_process(delta):
	if is_multiplayer_authority():
		var velocity = Vector3.ZERO
		if Input.is_action_pressed("ui_up"):
			velocity.z -= 1
		if Input.is_action_pressed("ui_down"):
			velocity.z += 1
		if Input.is_action_pressed("ui_left"):
			velocity.x -= 1
		if Input.is_action_pressed("ui_right"):
			velocity.x += 1
		if velocity.length() > 1:
			velocity = velocity.normalized()
		velocity = global_transform.basis * velocity
		self.velocity = velocity * speed
		move_and_slide()
		rpc("update_puppet_transform", global_transform)
	else:
		global_transform = puppet_transform

@rpc("reliable")
func update_puppet_transform(transform):
	puppet_transform = transform
