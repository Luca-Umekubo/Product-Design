extends RigidBody3D

var is_active = true
var spawn_immunity_time = 0.2
var last_hit_player = null
var team_color = null
var has_bounced = false  # Track if the ball has hit the ground

func _ready():
	collision_layer = 2
	collision_mask = 1 | 2 | 4
	body_entered.connect(_on_body_entered)
	
	var physics_material = PhysicsMaterial.new()
	physics_material.friction = 0.5
	physics_material.bounce = 0.7
	physics_material_override = physics_material
	
	mass = 2.0
	custom_integrator = false
	continuous_cd = true
	max_contacts_reported = 5
	contact_monitor = true
	
	collision_layer = 2
	collision_mask = 1 | 2 | 4
	
	add_to_group("balls")
	
	apply_central_impulse(Vector3(0, 0.5, 0))
	
	set_deferred("monitoring", false)
	var timer = get_tree().create_timer(spawn_immunity_time)
	timer.timeout.connect(func(): set_deferred("monitoring", true))
	
	# Set initial neutral color
	apply_neutral_color()
	
	# Set initial gravity_scale and connect to gravity multiplier changes
	gravity_scale = GameState.gravity_multiplier
	GameState.gravity_multiplier_changed.connect(_on_gravity_multiplier_changed)

# Callback for when gravity multiplier changes
func _on_gravity_multiplier_changed(new_value: float):
	gravity_scale = new_value

func _physics_process(delta):
	if linear_velocity.length() < 3.0 and linear_velocity.length() > 0.1:
		linear_velocity = linear_velocity * 0.98
	
	if is_active and abs(linear_velocity.y) < 0.01 and is_on_floor():
		apply_central_impulse(Vector3(0, 0.2, 0))

func is_on_floor():
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(
		global_position,
		global_position + Vector3(0, -0.55, 0)
	)
	query.exclude = [self]
	var result = space_state.intersect_ray(query)
	return result != null

func apply_team_color(team_index):
	# Apply team color to the ball
	var material = preload("res://team_colors.gd").create_team_material(team_index)
	$MeshInstance3D.material_override = material
	team_color = team_index

func apply_neutral_color():
	# Apply neutral color (when no team has ownership)
	var material = preload("res://team_colors.gd").create_team_material(-1)
	$MeshInstance3D.material_override = material
	team_color = null

func _on_body_entered(body):
	if not multiplayer.is_server():
		return
		
	if body.is_in_group("players"):
		if last_hit_player != null and body.team != last_hit_player.team:
			var current_scene = get_tree().current_scene
			if current_scene.name == "Lobby":
				if body.has_method("respawn"):
					body.respawn.rpc()
				else:
					body.global_position = Vector3.ZERO
					body.linear_velocity = Vector3.ZERO
				global_position = Vector3.ZERO
				linear_velocity = Vector3.ZERO
			else:
				if linear_velocity.length() > 5.0 and not has_bounced:
				# Notify server of hit only if the ball hasn't bounced
					get_tree().get_root().get_node("Game").player_hit(body.name)
					
					var bounce_direction = (global_position - body.global_position).normalized()
					linear_velocity = bounce_direction * linear_velocity.length() * 0.7
					linear_velocity.y += 2.0
					
					last_hit_player = body
					
					# Apply color of the last player who hit the ball
					if last_hit_player.team != null:
						update_ball_color.rpc(last_hit_player.team)
					
					set_deferred("monitoring", false)
					var timer = get_tree().create_timer(0.5)
					timer.timeout.connect(func(): 
						set_deferred("monitoring", true)
						last_hit_player = null
					)
				else:
					var push_direction = (global_position - body.global_position).normalized()
					apply_central_impulse(push_direction * 3.0)
		elif body.is_in_group("players"):
			# When a player of any team touches the ball, update the color
			last_hit_player = body
			update_ball_color.rpc(body.team)
	else:
		# Check if the collided body is the ground
		if body.is_in_group("ground"):
			has_bounced = true  # Mark the ball as having bounced

@rpc("authority", "call_local")
func update_ball_color(team_index):
	apply_team_color(team_index)
