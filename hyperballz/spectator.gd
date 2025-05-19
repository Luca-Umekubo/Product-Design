# Spectator.gd
extends Node3D

var speed = 10.0  # Movement speed
var mouse_sensitivity = 0.1  # Mouse look sensitivity

func _ready():
	# Activate the camera and capture the mouse if this is the local player
	if is_multiplayer_authority():
		$Camera3D.current = true
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	# Handle mouse movement for camera rotation
	if is_multiplayer_authority() and event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity))
		$Camera3D.rotate_x(deg_to_rad(-event.relative.y * mouse_sensitivity))

func _process(delta):
	# Handle WASD movement
	if is_multiplayer_authority():
		var direction = Vector3()
		if Input.is_action_pressed("ui_up"):
			direction -= transform.basis.z  # Forward
		if Input.is_action_pressed("ui_down"):
			direction += transform.basis.z  # Backward
		if Input.is_action_pressed("ui_left"):
			direction -= transform.basis.x  # Left
		if Input.is_action_pressed("ui_right"):
			direction += transform.basis.x  # Right
		direction = direction.normalized()
		translate(direction * speed * delta)
