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
var lives = 2  # Player starts with 2 lives
var is_spectator = false
var team = 0  # Default team is 0

# Team colors (can be customized)
var team_colors = {
	0: Color(0.2, 0.5, 1.0),  # Blue for team 0
	1: Color(1.0, 0.2, 0.2)   # Red for team 1
}

# Optional reference to a hit material for visual feedback
var hit_material = null
var team_material = null

# Networked animation state
var current_animation: String = "Idle" : set = _set_current_animation
var is_animation_backward: bool = false
var animation_speed: float = 1.0

func _ready():
	add_to_group("players")
	
	if get_multiplayer_authority() == multiplayer.get_unique_id():
		camera.make_current()
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		print("Player ", name, " authority: ", get_multiplayer_authority(), " camera active: ", camera.is_current())
	else:
		camera.current = false
		print("Player ", name, " non-authoritative, camera disabled")
	
	# Load materials
	if ResourceLoader.exists("res://hit_material.tres"):
		hit_material = load("res://hit_material.tres")
	
	if get_multiplayer_authority() == multiplayer.get_unique_id() and multiplayer.has_multiplayer_peer():
		camera.current = true
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		
		# Request team information from the server
		request_team_info.rpc_id(1, multiplayer.get_unique_id())
	
	# Initialize animation for all clients
	_set_current_animation("Idle")
	
	# Set roll_duration to the length of the Roll animation
	if animation_player.has_animation("Roll"):
		roll_duration = animation_player.get_animation("Roll").length

# Request team info from the server
@rpc("any_peer")
func request_team_info(peer_id):
	if multiplayer.is_server():
		var game = get_tree().get_root().get_node_or_null("Game")
		if game and game.team_assignments.has(peer_id):
			var assigned_team = game.team_assignments[peer_id]
			set_team.rpc_id(peer_id, assigned_team)

# Set the team for this player (called by server)
@rpc("authority", "call_local")
func set_team(team_id):
	team = team_id
	print("Player ", name, " is on team ", team)
	
	# Apply team visual indicator
	apply_team_visuals()

# Apply team-specific visual indicators
func apply_team_visuals():
	var mannequin = get_node("AnimationLibrary_Godot_Standard/Rig/Skeleton3D/Mannequin")
	if mannequin:
		# Create a new material if needed
		if not team_material:
			# Clone the existing material if possible
			if mannequin.get_surface_override_material(0):
				team_material = mannequin.get_surface_override_material(0).duplicate()
			else:
				team_material = StandardMaterial3D.new()
		
		# Set the team color
		if team_colors.has(team):
			team_material.albedo_color = team_colors[team]
			mannequin.set_surface_override_material(0, team_material)

func _input(event):
	if get_multiplayer_authority() == multiplayer.get_unique_id():
		# Toggle mouse mode and movement on Escape key press
		if event is InputEventKey and event.is_action_pressed("ui_cancel"):
			if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
				# Disable movement (e.g., by setting a flag or disabling input processing)
				set_physics_process(false)
			else:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
				# Enable movement
				set_physics_process(true)
		
		# Handle mouse movement for camera when mouse is captured
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED and multiplayer.has_multiplayer_peer() and event is InputEventMouseMotion:
			rotate_y(-event.relative.x * mouse_sensitivity)
			camera.rotate_x(-event.relative.y * mouse_sensitivity)
			camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)
	
	# Prevent throwing balls in spectator mode
	if event.is_action_pressed("throw") and not is_spectator and not is_throwing and not is_rolling:
		start_throw_animation()

func _physics_process(delta):
	if get_multiplayer_authority() == multiplayer.get_unique_id(): 
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

# Setter for current_animation to ensure it's applied
func _set_current_animation(value: String):
	current_animation = value
	if is_inside_tree():
		_apply_animation()

func start_roll(input_dir: Vector3):
	if get_multiplayer_authority() == multiplayer.get_unique_id():
		is_rolling = true
		roll_timer = roll_duration
		# Use input direction or forward if no input
		roll_direction = input_dir if input_dir != Vector3.ZERO else -transform.basis.z
		roll_direction = roll_direction.normalized()
		update_animation.rpc("Roll", false, 1.0)

func start_throw_animation():
	if get_multiplayer_authority() == multiplayer.get_unique_id() and not is_jumping and not is_dancing and not is_rolling:
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
		if get_multiplayer_authority() == multiplayer.get_unique_id():
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
		return
		
	print("Server: Spawning ball for player ", name, " with team ", team)
	
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
		"velocity": spawn_velocity,
		"team": team  # Include the team info for potential team-based ball mechanics
	}
	
	print("Ball data: ", ball_data)
	
	var root = get_tree().get_root()
	var ball_spawner_path = "Game/Balls/BallSpawner" if root.has_node("Game") else "Lobby/Balls/BallSpawner"
	if root.has_node(ball_spawner_path):
		print("Found ball spawner at: ", ball_spawner_path)
		root.get_node(ball_spawner_path).spawn(ball_data)
	else:
		push_error("BallSpawner not found at path: " + ball_spawner_path)

@rpc("call_local")
func update_lives(new_lives):
	# Update lives locally; actual tracking is done on server
	if multiplayer.has_multiplayer_peer() and get_multiplayer_authority() == multiplayer.get_unique_id():
		if hit_material != null and new_lives > 0:
			$MeshInstance3D.material_override = hit_material
			var timer = get_tree().create_timer(0.3)
			timer.timeout.connect(func(): $MeshInstance3D.material_override = null)
		print("Player ", name, " lives: ", new_lives)

@rpc("call_local")
func set_spectator_mode():
	if multiplayer.has_multiplayer_peer() and get_multiplayer_authority() == multiplayer.get_unique_id():
		is_spectator = true
		# Disable collisions
		collision_layer = 0
		collision_mask = 0
		# Hide player model
		var mannequin = get_node("AnimationLibrary_Godot_Standard/Rig/Skeleton3D/Mannequin")
		mannequin.visible = false
		# Ensure camera remains active
		camera.current = true
		print("Player ", name, " entered spectator mode")

@rpc("any_peer", "call_local")
func respawn():
	print("Player " + name + ": respawn RPC received - from peer: " + str(multiplayer.get_remote_sender_id()))
	
	if multiplayer.has_multiplayer_peer():
		# Check if we're the player who should be respawning
		var my_id = multiplayer.get_unique_id()
		var player_id = int(name)
		
		# Only execute the respawn if this is OUR player
		if my_id == player_id:
			print("CRITICAL: Respawning my player (ID: " + str(my_id) + ")")
			
			var team_spawn_points = get_tree().get_nodes_in_group("team" + str(team) + "_spawn")
			var spawn_points = team_spawn_points
			
			# Fall back to generic spawn points if team-specific ones aren't found
			if spawn_points.size() == 0:
				spawn_points = get_tree().get_nodes_in_group("spawn_points")
				
			if spawn_points.size() > 0:
				var spawn_point = spawn_points[randi() % spawn_points.size()]
				position = spawn_point.global_position
				update_animation.rpc("Idle", false, 1.0)
				print("SUCCESS: Player ", name, " respawned at team ", team, " spawn point")
			else:
				# Emergency fallback if no spawn points exist
				position = Vector3.ZERO
				print("WARNING: No spawn points found, respawned player at origin")
			
			# Reset collision and visibility
			collision_layer = 1  # Restore default player layer
			collision_mask = 2 | 3  # Collide with balls and environment
			var mannequin = get_node_or_null("AnimationLibrary_Godot_Standard/Rig/Skeleton3D/Mannequin")
			if mannequin:
				mannequin.visible = true
			is_spectator = false
		else:
			print("Not executing respawn - this is player " + str(player_id) + " but I am peer " + str(my_id))
