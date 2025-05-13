extends CharacterBody3D

@onready var animation_player = $AnimationLibrary_Godot_Standard/AnimationPlayer
@onready var camera = $Camera3D
var speed = 5.0
var sprint_speed = 8.0
var roll_speed = 10.0  # Speed during roll
var roll_duration = 0.5  # Will be set dynamically to animation length
var mouse_sensitivity = 0.005
var gravity = -9.8
var jump_strength = 4.5
var is_jumping = false
var is_dancing = false
var is_moving_backward = false
var is_throwing = false
var is_rolling = false
var roll_timer = 0.0
var roll_direction = Vector3.ZERO

# Networked animation state
var current_animation: String = "Idle" : set = _set_current_animation
var is_animation_backward: bool = false
var animation_speed: float = 1.0

func _ready():
	add_to_group("players")
	if is_multiplayer_authority():
		camera.current = true
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	# Initialize animation for all clients
	_set_current_animation("Idle")
	# Set roll_duration to the length of the Roll animation
	if animation_player.has_animation("Roll"):
		roll_duration = animation_player.get_animation("Roll").length

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
		if Input.is_action_just_pressed("dance") and not is_jumping and not is_rolling:
			is_dancing = true
			update_animation.rpc("Dance", false, 1.0)

		# Cancel dancing if moving
		if is_dancing and input_dir != Vector3.ZERO:
			is_dancing = false

		# Handle rolling
		if Input.is_action_just_pressed("roll_input") and is_on_floor() and not is_jumping and not is_dancing and not is_throwing:
			start_roll(input_dir)

		# Update roll timer
		if is_rolling:
			roll_timer -= delta
			# Only end rolling when both timer expires and animation finishes
			if roll_timer <= 0 and not animation_player.is_playing() and current_animation == "Roll":
				is_rolling = false
				# Return to previous animation state after roll
				var current_input_dir = Vector3.ZERO
				current_input_dir.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
				current_input_dir.z = Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")
				current_input_dir = current_input_dir.normalized()
				if current_input_dir != Vector3.ZERO:
					if Input.is_action_pressed("sprint"):
						update_animation.rpc("Sprint", current_input_dir.z > 0, 1.0)
					else:
						update_animation.rpc("Walk", current_input_dir.z > 0, 1.0)
				else:
					update_animation.rpc("Idle", false, 1.0)

		# Calculate movement direction and speed
		var current_speed = speed
		if Input.is_action_pressed("sprint") and input_dir != Vector3.ZERO and not is_jumping and not is_dancing and not is_rolling:
			current_speed = sprint_speed

		var move_direction = input_dir * current_speed
		if is_rolling:
			move_direction = roll_direction * roll_speed
		move_direction = move_direction.rotated(Vector3.UP, rotation.y)

		# Update velocity (no movement if dancing)
		if not is_dancing:
			velocity.x = move_direction.x
			velocity.z = move_direction.z
		else:
			velocity.x = 0
			velocity.z = 0

		# Handle jumping
		if Input.is_action_just_pressed("jump") and is_on_floor() and not is_dancing and not is_rolling:
			velocity.y = jump_strength
			is_jumping = true
			update_animation.rpc("Jump_Start", false, 1.0)

		# Apply movement
		move_and_slide()

		# Animation logic (authoritative client only)
		if is_throwing:
			pass  # Let the throw animation sequence handle itself
		elif is_rolling:
			if current_animation != "Roll":
				update_animation.rpc("Roll", false, 1.0)
		elif is_dancing:
			if current_animation != "Dance":
				update_animation.rpc("Dance", false, 1.0)
		elif is_jumping:
			if current_animation == "Jump_Start" and not animation_player.is_playing():
				update_animation.rpc("Jump", false, 1.0)
			elif is_on_floor() and current_animation != "Jump_Land":
				update_animation.rpc("Jump_Land", false, 1.0)
		else:
			# Determine if moving backward
			var moving_backward = input_dir.z > 0
			if moving_backward != is_moving_backward:
				is_moving_backward = moving_backward

			# Handle movement animations
			if input_dir != Vector3.ZERO:
				if Input.is_action_pressed("sprint"):
					if current_animation != "Sprint" or is_animation_backward != is_moving_backward:
						update_animation.rpc("Sprint", is_moving_backward, 1.0)
				else:
					if current_animation != "Walk" or is_animation_backward != is_moving_backward:
						update_animation.rpc("Walk", is_moving_backward, 1.0)
			else:
				if current_animation != "Idle":
					update_animation.rpc("Idle", false, 1.0)

	# Handle throwing animation sequence
	if Input.is_action_just_pressed("throw") and not is_throwing and not is_rolling:
		start_throw_animation()

# RPC to update animation state across all clients
@rpc("any_peer", "call_local", "reliable")
func update_animation(anim_name: String, backward: bool, speed: float):
	current_animation = anim_name
	is_animation_backward = backward
	animation_speed = speed
	_apply_animation()

# Apply animation state locally
func _apply_animation():
	if animation_player.current_animation != current_animation:
		animation_player.play(current_animation, -1, animation_speed)
	if is_animation_backward:
		animation_player.play_backwards(current_animation)
	else:
		animation_player.play(current_animation, -1, animation_speed)

# Setter for current_animation to ensure it’s applied
func _set_current_animation(value: String):
	current_animation = value
	if is_inside_tree():
		_apply_animation()

func start_roll(input_dir: Vector3):
	if is_multiplayer_authority():
		is_rolling = true
		roll_timer = roll_duration
		# Use input direction or forward if no input
		roll_direction = input_dir if input_dir != Vector3.ZERO else -transform.basis.z
		roll_direction = roll_direction.normalized()
		update_animation.rpc("Roll", false, 1.0)

func start_throw_animation():
	if is_multiplayer_authority() and not is_jumping and not is_dancing and not is_rolling:
		is_throwing = true
		# Play Enter animation at double speed
		update_animation.rpc("Spell_Simple_Enter", false, 2.0)
		await animation_player.animation_finished
		# Play Shoot animation at double speed and trigger throw
		update_animation.rpc("Spell_Simple_Shoot", false, 2.0)
		# Request the server to spawn the ball
		spawn_ball.rpc_id(1) # Call the server (peer ID 1 is the server in Godot multiplayer)
		await animation_player.animation_finished
		# Play Exit animation at double speed
		update_animation.rpc("Spell_Simple_Exit", false, 2.0)
		await animation_player.animation_finished
		# Return to previous animation
		if is_multiplayer_authority():
			var input_dir = Vector3.ZERO
			input_dir.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
			input_dir.z = Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")
			input_dir = input_dir.normalized()
			if input_dir != Vector3.ZERO:
				if Input.is_action_pressed("sprint"):
					update_animation.rpc("Sprint", input_dir.z > 0, 1.0)
				else:
					update_animation.rpc("Walk", input_dir.z > 0, 1.0)
			else:
				update_animation.rpc("Idle", false, 1.0)
		is_throwing = false

@rpc("any_peer", "call_local", "reliable")
func spawn_ball():
	if not multiplayer.is_server():
		return  # Only the server spawns the ball
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
			update_animation.rpc("Idle", false, 1.0)
