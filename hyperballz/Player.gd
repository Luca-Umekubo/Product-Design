extends CharacterBody3D

@onready var animation_player = $AnimationLibrary_Godot_Standard/AnimationPlayer
@onready var camera = $Camera3D
var speed = 5.0
var sprint_speed = 8.0
var mouse_sensitivity = 0.005
var gravity = -9.8
var jump_strength = 4.5
var is_jumping = false
var is_dancing = false
var is_moving_backward = false
var is_throwing = false

func _ready():
	add_to_group("players")
	if is_multiplayer_authority():
		camera.current = true
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		animation_player.play("Idle")

func _input(event):
	if is_multiplayer_authority() and event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)
		camera.rotate_x(-event.relative.y * mouse_sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)

func _physics_process(delta):
	if is_multiplayer_authority():
		# Handle gravity
		if not is_on_floor():
			velocity.y += gravity * delta
		else:
			velocity.y = 0
			is_jumping = false

		# Get input direction
		var input_dir = Vector3.ZERO
		input_dir.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
		input_dir.z = Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")
		input_dir = input_dir.normalized()

		# Handle dancing
		if Input.is_action_just_pressed("dance") and not is_jumping:
			is_dancing = true
			animation_player.play("Dance")

		# Cancel dancing if moving
		if is_dancing and input_dir != Vector3.ZERO:
			is_dancing = false

		# Calculate movement direction and speed
		var current_speed = speed
		if Input.is_action_pressed("sprint") and input_dir != Vector3.ZERO and not is_jumping and not is_dancing:
			current_speed = sprint_speed

		var move_direction = input_dir * current_speed
		move_direction = move_direction.rotated(Vector3.UP, rotation.y)

		# Update velocity (no movement if dancing)
		if not is_dancing:
			velocity.x = move_direction.x
			velocity.z = move_direction.z
		else:
			velocity.x = 0
			velocity.z = 0

		# Handle jumping
		if Input.is_action_just_pressed("jump") and is_on_floor() and not is_dancing:
			velocity.y = jump_strength
			is_jumping = true
			animation_player.play("Jump_Start")

		# Apply movement
		move_and_slide()

		# Animation logic (skip movement animations if throwing)
		if is_throwing:
			pass  # Let the throw animation sequence handle itself
		elif is_dancing:
			if animation_player.current_animation != "Dance":
				animation_player.play("Dance")
		elif is_jumping:
			if animation_player.current_animation == "Jump_Start" and not animation_player.is_playing():
				animation_player.play("Jump")
			elif is_on_floor() and animation_player.current_animation != "Jump_Land":
				animation_player.play("Jump_Land")
			# Keep playing Jump while in the air
		else:
			# Determine if moving backward
			var moving_backward = input_dir.z > 0
			# Only update direction if it changes
			if moving_backward != is_moving_backward:
				is_moving_backward = moving_backward
				if animation_player.current_animation in ["Walk", "Sprint"]:
					if is_moving_backward:
						animation_player.play_backwards(animation_player.current_animation)
					else:
						animation_player.play(animation_player.current_animation)

			# Handle movement animations
			if input_dir != Vector3.ZERO:
				if Input.is_action_pressed("sprint"):
					if animation_player.current_animation != "Sprint":
						animation_player.play("Sprint")
						if is_moving_backward:
							animation_player.play_backwards("Sprint")
				else:
					if animation_player.current_animation != "Walk":
						animation_player.play("Walk")
						if is_moving_backward:
							animation_player.play_backwards("Walk")
			else:
				if animation_player.current_animation != "Idle":
					animation_player.play("Idle")

		# Handle throwing animation sequence
		if Input.is_action_just_pressed("throw") and not is_throwing:
			start_throw_animation()

func start_throw_animation():
	if is_multiplayer_authority() and not is_jumping and not is_dancing:
		is_throwing = true
		# Play Enter animation at double speed
		animation_player.play("Spell_Simple_Enter", -1, 2.0)
		await animation_player.animation_finished
		# Play Shoot animation at double speed and trigger throw
		animation_player.play("Spell_Simple_Shoot", -1, 2.0)
		throw_ball()
		await animation_player.animation_finished
		# Play Exit animation at double speed
		animation_player.play("Spell_Simple_Exit", -1, 2.0)
		await animation_player.animation_finished
		# Return to previous animation (e.g., Idle or Walk)
		if animation_player.current_animation == "Spell_Simple_Exit":
			var input_dir = Vector3.ZERO
			input_dir.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
			input_dir.z = Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")
			input_dir = input_dir.normalized()
			if input_dir != Vector3.ZERO:
				if Input.is_action_pressed("sprint"):
					animation_player.play("Sprint")
					if input_dir.z > 0:
						animation_player.play_backwards("Sprint")
				else:
					animation_player.play("Walk")
					if input_dir.z > 0:
						animation_player.play_backwards("Walk")
			else:
				animation_player.play("Idle")
		is_throwing = false

func throw_ball():
	if not multiplayer.is_server():
		print("Not server, skipping ball spawn")
		return
	var ball_spawner = get_tree().get_root().get_node("Game/Balls/BallSpawner")
	if ball_spawner:
		var spawn_position = $Camera3D/BallSpawnPoint.global_position
		var spawn_velocity = $Camera3D.global_transform.basis.z * -10
		var ball_data = {
			"position": spawn_position,
			"velocity": spawn_velocity
		}
		print("Spawning ball with data:", ball_data)
		ball_spawner.spawn(ball_data)
	else:
		print("BallSpawner not found!")

@rpc("authority")
func respawn():
	if is_multiplayer_authority():
		var spawn_points = get_tree().get_nodes_in_group("spawn_points")
		if spawn_points.size() > 0:
			var spawn_point = spawn_points[randi() % spawn_points.size()]
			position = spawn_point.global_position
