extends RigidBody3D

var is_active = true
var respawn_timer = 0.0
var max_respawn_time = 15.0
var spawn_immunity_time = 0.2
var last_hit_player = null
var team = -1  # -1 means neutral, 0 or 1 for team-specific balls

# Team colors (should match player team colors)
var team_colors = {
	-1: Color(1.0, 1.0, 1.0),  # White for neutral
	0: Color(0.2, 0.5, 1.0),   # Blue for team 0
	1: Color(1.0, 0.2, 0.2)    # Red for team 1
}

func _ready():
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
	
	# Apply team-specific color if needed
	if team >= 0:
		apply_team_color()

# Apply color based on team
func apply_team_color():
	if team in team_colors:
		var ball_mesh = get_node_or_null("MeshInstance3D")
		if ball_mesh:
			var material = StandardMaterial3D.new()
			material.albedo_color = team_colors[team]
			ball_mesh.material_override = material
			print("Applied team color ", team_colors[team], " to ball for team ", team)

func _physics_process(delta):
	if is_active and linear_velocity.length() < 0.1:
		respawn_timer += delta
		if respawn_timer > max_respawn_time:
			queue_free()
	else:
		respawn_timer = 0.0
	
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

func _on_body_entered(body):
	if not multiplayer.is_server():
		return
		
	if body.is_in_group("players"):
		var current_scene = get_tree().current_scene
		if current_scene.name == "Lobby": # Adjust "Lobby" to match your scene name
			print("Ball hit player in lobby: ", body.name)
			
			# Convert body name to player ID
			var hit_player_id = int(body.name)
			print("CRITICAL: Player hit - ID: ", hit_player_id)
			
			# Direct RPC to the correct player (target by ID)
			if body.has_method("respawn"):
				# Use rpc_id to explicitly target the respawn call to this specific player
				if hit_player_id > 0:
					# Call respawn directly on the player node targeting their peer ID
					body.rpc_id(hit_player_id, "respawn")
					print("CRITICAL: Sent respawn RPC to player ID: ", hit_player_id)
				else:
					print("ERROR: Invalid player ID: ", hit_player_id)
			else:
				print("ERROR: Player body doesn't have respawn method!")
				body.global_position = Vector3.ZERO # Fallback
				
			global_position = Vector3.ZERO # Reset ball position
			linear_velocity = Vector3.ZERO
		else:
			# Debug output
			print("Ball hit player: ", body.name, " - Ball team: ", team, " - Player team: ", body.get("team", -1))
			
			# Check if the ball is hitting a player from the same team
			var player_team = -1
			if body.has("team"):
				player_team = body.team
			
			# Team mechanics - don't damage teammates if the ball has a team
			if team >= 0 and team == player_team:
				# Slight bounce off teammates
				var bounce_direction = (global_position - body.global_position).normalized()
				linear_velocity = bounce_direction * linear_velocity.length() * 0.5
				linear_velocity.y += 1.0
				print("Teammate hit, bouncing off")
			elif linear_velocity.length() > 5.0:
				# Notify server of hit instead of calling player RPC
				print("Valid hit on opponent, triggering hit effect")
				
				# Make sure we're directly notifying the Game node
				var game_node = get_tree().get_root().get_node_or_null("Game")
				if game_node and game_node.has_method("player_hit"):
					game_node.player_hit(body.name)
					print("Successfully called player_hit on Game node")
				else:
					print("Failed to find Game node or player_hit method")
				
				var bounce_direction = (global_position - body.global_position).normalized()
				linear_velocity = bounce_direction * linear_velocity.length() * 0.7
				linear_velocity.y += 2.0
				
				last_hit_player = body
				
				set_deferred("monitoring", false)
				var timer = get_tree().create_timer(0.5)
				timer.timeout.connect(func(): 
					set_deferred("monitoring", true)
					last_hit_player = null
				)
			else:
				var push_direction = (global_position - body.global_position).normalized()
				apply_central_impulse(push_direction * 3.0)
				print("Ball too slow for hit, just pushed")

# Used when the ball is spawned with team data
func set_team(team_id):
	team = team_id
	apply_team_color()
