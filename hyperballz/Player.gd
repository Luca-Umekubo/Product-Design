extends CharacterBody3D

@onready var animation_player = $AnimationLibrary_Godot_Standard/AnimationPlayer
@onready var camera = $Camera3D
var speed = 5.0
var sprint_speed = 8.0
var roll_speed = 10.0
var roll_duration = 0.5
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
var lives = 2

# Throw charging variables
var is_charging_throw = false
var throw_start_time = 0.0
var throw_multiplier = 1.0

var hit_material = null

# Networked animation state
var current_animation: String = "Idle" : set = _set_current_animation
var is_animation_backward: bool = false
var animation_speed: float = 1.0

func _ready():
	add_to_group("players")
	if ResourceLoader.exists("res://hit_material.tres"):
		hit_material = load("res://hit_material.tres")
	if multiplayer.has_multiplayer_peer() and is_multiplayer_authority():
		camera.current = true
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	_set_current_animation("Idle")
	if animation_player.has_animation("Roll"):
		roll_duration = animation_player.get_animation("Roll").length

func _input(event):
	if multiplayer.has_multiplayer_peer() and is_multiplayer_authority() and event is InputEventMouseMotion:
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
			
		var input_vector = Vector2(
			Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
			Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")
		).normalized()

		var input_dir = Vector3.ZERO
		input_dir.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
		input_dir.z = Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")
		input_dir = input_dir.normalized()

		# Handle throw charging
		if Input.is_action_just_pressed("throw") and not is_throwing and not is_rolling:
			is_charging_throw = true
			throw_start_time = Time.get_ticks_msec() / 1000.0
			update_animation.rpc("Spell_Simple_Enter", false, 2.0)

		if is_charging_throw and Input.is_action_just_released("throw"):
			is_charging_throw = false
			var hold_time = (Time.get_ticks_msec() / 1000.0) - throw_start_time
			throw_multiplier = 2.5 if hold_time <= 1.5 else 6.0
			start_throw_animation(throw_multiplier)

		# Calculate movement speed
		var current_speed = speed
		if is_charging_throw:
			current_speed *= 0.5  # Slow down while charging
		elif Input.is_action_pressed("sprint") and input_dir != Vector3.ZERO and not is_jumping and not is_dancing and not is_rolling:
			current_speed = sprint_speed

		# Handle dancing
		if Input.is_action_just_pressed("dance") and not is_jumping and not is_rolling:
			is_dancing = true
			update_animation.rpc("Dance", false, 1.0)

		if is_dancing and input_dir != Vector3.ZERO:
			is_dancing = false

		# Handle rolling
		if Input.is_action_just_pressed("roll_input") and is_on_floor() and not is_jumping and not is_dancing and not is_throwing:
			start_roll(input_dir)

		if is_rolling:
			roll_timer -= delta
			if roll_timer <= 0 and not animation_player.is_playing() and current_animation == "Roll":
				is_rolling = false
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

		var move_direction = input_dir * current_speed
		if is_rolling:
			move_direction = roll_direction * roll_speed
		move_direction = move_direction.rotated(Vector3.UP, rotation.y)

		if not is_dancing:
			velocity.x = move_direction.x
			velocity.z = move_direction.z
		else:
			velocity.x = 0
			velocity.z = 0

		if Input.is_action_just_pressed("jump") and is_on_floor() and not is_dancing and not is_rolling:
			velocity.y = jump_strength
			is_jumping = true
			update_animation.rpc("Jump_Start", false, 1.0)

		move_and_slide()
		
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

		if is_throwing:
			pass
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
			var moving_backward = input_dir.z > 0
			if moving_backward != is_moving_backward:
				is_moving_backward = moving_backward
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

@rpc("any_peer", "call_local", "reliable")
func update_animation(anim_name: String, backward: bool, speed: float):
	current_animation = anim_name
	is_animation_backward = backward
	animation_speed = speed
	_apply_animation()

func _apply_animation():
	if animation_player.current_animation != current_animation:
		animation_player.play(current_animation, -1, animation_speed)
	if is_animation_backward:
		animation_player.play_backwards(current_animation)
	else:
		animation_player.play(current_animation, -1, animation_speed)

func _set_current_animation(value: String):
	current_animation = value
	if is_inside_tree():
		_apply_animation()

func start_roll(input_dir: Vector3):
	if is_multiplayer_authority():
		is_rolling = true
		roll_timer = roll_duration
		roll_direction = input_dir if input_dir != Vector3.ZERO else -transform.basis.z
		roll_direction = roll_direction.normalized()
		update_animation.rpc("Roll", false, 1.0)

func start_throw_animation(multiplier: float = 1.0):
	if is_multiplayer_authority() and not is_jumping and not is_dancing and not is_rolling:
		is_throwing = true
		update_animation.rpc("Spell_Simple_Enter", false, 2.0)
		await animation_player.animation_finished
		update_animation.rpc("Spell_Simple_Shoot", false, 2.0)
		spawn_ball.rpc_id(1, multiplier)
		await animation_player.animation_finished
		update_animation.rpc("Spell_Simple_Exit", false, 2.0)
		await animation_player.animation_finished
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
func spawn_ball(multiplier: float = 1.0):
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
	var base_speed = 10.0
	var spawn_velocity = spawn_direction * base_speed * multiplier
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
			respawn()
		else:
			if hit_material != null:
				$MeshInstance3D.material_override = hit_material
				var timer = get_tree().create_timer(0.3)
				timer.timeout.connect(func(): $MeshInstance3D.material_override = null)

@rpc("authority", "call_local")
func update_lives(new_lives):
	lives = new_lives
	print("Player ", name, " lives: ", lives)

@rpc("authority")
func respawn():
	if multiplayer.has_multiplayer_peer() and is_multiplayer_authority():
		lives = 2
		update_lives.rpc(lives)
		var spawn_points = get_tree().get_nodes_in_group("spawn_points")
		if spawn_points.size() > 0:
			var spawn_point = spawn_points[randi() % spawn_points.size()]
			position = spawn_point.global_position
			update_animation.rpc("Idle", false, 1.0)
