extends Node3D

@onready var multiplayer_spawner = $Players/MultiplayerSpawner
@onready var ball_spawner = $Balls/BallSpawner
var team_assignments = {}  # Tracks which team each player is on (peer_id: team)
var team_counts = {0: 0, 1: 0}  # Keeps track of how many players are on each team

func _ready():
	multiplayer_spawner.spawn_function = _spawn_player
	ball_spawner.spawn_function = _spawn_ball
	multiplayer_spawner.set_multiplayer_authority(1)
	ball_spawner.set_multiplayer_authority(1)
	
	if multiplayer.is_server():
		var peer_ids = multiplayer.get_peers()
		peer_ids.append(multiplayer.get_unique_id())  # Include the server itself
		
		# Host is always assigned to team 0
		_assign_team_to_player(multiplayer.get_unique_id(), 0)
		
		# Assign teams to all connected players at lobby start
		for peer_id in peer_ids:
			if peer_id != multiplayer.get_unique_id():  # Skip the host as it's already assigned
				_assign_team_to_player(peer_id)
				
			var player_data = {"peer_id": peer_id, "team": team_assignments[peer_id]}
			print("Lobby: Spawning player with data: ", player_data)
			multiplayer_spawner.spawn(player_data)
	
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)

# Assigns a team to a player, balancing teams if not specified
func _assign_team_to_player(peer_id, specific_team = -1):
	if specific_team >= 0:
		# Assign the specified team
		team_assignments[peer_id] = specific_team
		team_counts[specific_team] += 1
	else:
		# Automatically assign to create balanced teams
		if team_counts[0] <= team_counts[1]:
			team_assignments[peer_id] = 0
			team_counts[0] += 1
		else:
			team_assignments[peer_id] = 1
			team_counts[1] += 1
	
	print("Player ", peer_id, " assigned to team ", team_assignments[peer_id], 
		  " (Team 0: ", team_counts[0], ", Team 1: ", team_counts[1], ")")

func _on_peer_connected(id):
	if multiplayer.is_server():
		# Delay spawn to ensure peer is fully connected
		await get_tree().create_timer(0.5).timeout
		
		# Assign team to new player
		_assign_team_to_player(id)
		
		var client_data = {
			"peer_id": id,
			"team": team_assignments[id]
		}
		print("Lobby: Spawning client with data: ", client_data)
		multiplayer_spawner.spawn(client_data)
		
		# Send team assignments to all clients for UI updates
		sync_team_assignments.rpc(team_assignments)

func _on_peer_disconnected(id):
	if multiplayer.is_server():
		# Remove player and update team counts
		if $Players.has_node(str(id)):
			$Players.get_node(str(id)).queue_free()
		
		# Update team counts when a player disconnects
		if team_assignments.has(id):
			var team = team_assignments[id]
			team_counts[team] -= 1
			print("Player ", id, " disconnected from team ", team, 
				  " (Team 0: ", team_counts[0], ", Team 1: ", team_counts[1], ")")
			
			team_assignments.erase(id)
			
			# Sync updated team assignments
			sync_team_assignments.rpc(team_assignments)

func _spawn_player(data):
	var peer_id = data["peer_id"]
	var team = data["team"]
	var player = preload("res://Player.tscn").instantiate()
	player.name = str(peer_id)
	player.set_multiplayer_authority(peer_id)
	
	# Get spawn points for the appropriate team
	var team_spawn_points = get_tree().get_nodes_in_group("team" + str(team) + "_spawn")
	var spawn_points = team_spawn_points
	
	# Fall back to generic spawn points if team-specific ones aren't found
	if team_spawn_points.size() == 0:
		spawn_points = get_tree().get_nodes_in_group("spawn_points")
	
	if spawn_points.size() > 0:
		var spawn_point = spawn_points[randi() % spawn_points.size()]
		player.position = spawn_point.global_position
		print("Lobby: Spawned player ", peer_id, " on team ", team, " at ", player.position)
	else:
		print("Lobby: Warning: No spawn points found for peer ", peer_id, " (team ", team, ")")
	
	return player

func _spawn_ball(data):
	var ball = preload("res://Ball.tscn").instantiate()
	ball.position = data["position"]
	ball.linear_velocity = data["velocity"]
	
	# Assign team to ball if specified
	if "team" in data:
		ball.team = data["team"]
	
	print("Lobby: Spawning ball at ", data["position"])
	return ball

# Synchronize team assignments to all clients
@rpc("authority", "call_local")
func sync_team_assignments(assignments):
	# This will update all clients with the current team assignments
	# Can be used for UI elements showing team compositions
	team_assignments = assignments
	
	# Update local player team if needed
	if multiplayer.has_multiplayer_peer():
		var my_id = multiplayer.get_unique_id()
		if my_id in team_assignments:
			var my_player = get_node_or_null("Players/" + str(my_id))
			if my_player and "team" in my_player:
				my_player.set_team.rpc(team_assignments[my_id])

# Start game button pressed
func _on_start_game_button_pressed():
	if multiplayer.is_server():
		# Transfer team assignments to the game scene
		var team_data = {
			"team_assignments": team_assignments,
			"team_counts": team_counts
		}
		# Save team data for game scene to access
		save_game_data(team_data)
		
		# Tell all clients to change scene
		change_scene_to_game.rpc()

# Save game data to be accessed by the game scene
func save_game_data(data):
	# Create a temporary singleton to pass data between scenes
	var game_data = Node.new()
	game_data.name = "GameData"
	game_data.set_meta("team_assignments", data.team_assignments)
	game_data.set_meta("team_counts", data.team_counts)
	get_tree().root.add_child(game_data)

# Change scene to game
@rpc("authority", "call_local")
func change_scene_to_game():
	get_tree().change_scene_to_file("res://Game.tscn")
