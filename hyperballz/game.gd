extends Node3D

@onready var multiplayer_spawner = $Players/MultiplayerSpawner
@onready var ball_spawner = $Balls/BallSpawner
@onready var game_timer = $GameTimer
@onready var timer_sync = $TimerSync
var sync_interval = 0.5  # Update every 0.5 seconds
var time_since_last_sync = 0.0
var player_lives = {}  # Tracks lives for each player (peer_id: lives)
var team_assignments = {}  # Tracks which team each player is on (peer_id: team)
var team_counts = {0: 0, 1: 0}  # Keeps track of how many players are on each team

var game_active = false

func _ready():
	multiplayer_spawner.spawn_function = _spawn_player
	ball_spawner.spawn_function = _spawn_ball
	multiplayer_spawner.set_multiplayer_authority(1)
	ball_spawner.set_multiplayer_authority(1)
	
	if multiplayer.is_server():
		# Check if we have team data from the lobby
		var game_data = get_tree().root.get_node_or_null("GameData")
		if game_data:
			# Import team data from lobby
			team_assignments = game_data.get_meta("team_assignments")
			team_counts = game_data.get_meta("team_counts")
			game_data.queue_free()  # Clean up the temporary node
			print("Imported team data from lobby: ", team_assignments)
		else:
			# No data from lobby, initialize team assignments
			var peer_ids = multiplayer.get_peers()
			peer_ids.append(multiplayer.get_unique_id())  # Include the server itself
			
			# Host is always assigned to team 0
			_assign_team_to_player(multiplayer.get_unique_id(), 0)
			
			# Assign teams to all connected players at game start
			for peer_id in peer_ids:
				if peer_id != multiplayer.get_unique_id():  # Skip the host as it's already assigned
					_assign_team_to_player(peer_id)
		
		# Spawn all players with their assigned teams
		var peer_ids = multiplayer.get_peers()
		peer_ids.append(multiplayer.get_unique_id())  # Include the server itself
		for peer_id in peer_ids:
			# Initialize player lives
			player_lives[peer_id] = 2
			var player_data = {"peer_id": peer_id, "team": team_assignments[peer_id]}
			print("InGame: Spawning player with data: ", player_data)
			multiplayer_spawner.spawn(player_data)
		
		# Share team assignments with all clients
		sync_team_assignments.rpc(team_assignments)
		
		game_timer.wait_time = 300.0
		game_timer.one_shot = true
		game_timer.timeout.connect(_on_game_timer_timeout)
		start_game_timer()
	
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
	
# Synchronize team assignments to all clients
@rpc("authority", "call_local")
func sync_team_assignments(assignments):
	# This will update all clients with the current team assignments
	team_assignments = assignments
	
	# Update local player team if needed
	if multiplayer.has_multiplayer_peer():
		var my_id = multiplayer.get_unique_id()
		if my_id in team_assignments:
			var my_player = get_node_or_null("Players/" + str(my_id))
			if my_player and "team" in my_player:
				my_player.set_team.rpc(team_assignments[my_id])
				
func start_game_timer():
	if multiplayer.is_server() and not game_active:
		game_active = true
		game_timer.start()
		# Notify all clients to start their timer display
		update_timer_display.rpc(game_timer.wait_time)

# RPC to update timer display on clients
@rpc("authority", "call_local")
func update_timer_display(time_left):
	# Clients will update their UI with the time left
	# This will be implemented in the UI script
	pass

# Called when the timer reaches zero
func _on_game_timer_timeout():
	if multiplayer.is_server():
		game_active = false
		# Notify all clients that the game has ended
		end_game.rpc()

# RPC to end the game
@rpc("authority", "call_local")
func end_game():
	# Return to the home screen or show game over screen
	get_tree().change_scene_to_file("res://HomeScreen.tscn")

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
		print("Game: Spawning client with data: ", client_data)
		multiplayer_spawner.spawn(client_data)
		
		# Initialize lives for new player
		player_lives[id] = 2
		
	if multiplayer.is_server() and game_active:
		update_timer_display.rpc_id(id, game_timer.time_left)

func _on_peer_disconnected(id):
	if multiplayer.is_server():
		# Remove player and lives entry
		if $Players.has_node(str(id)):
			$Players.get_node(str(id)).queue_free()
		
		# Update team counts when a player disconnects
		if team_assignments.has(id):
			var team = team_assignments[id]
			team_counts[team] -= 1
			print("Player ", id, " disconnected from team ", team, 
				  " (Team 0: ", team_counts[0], ", Team 1: ", team_counts[1], ")")
			
			team_assignments.erase(id)
		
		player_lives.erase(id)

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
		print("Game: Spawned player ", peer_id, " on team ", team, " at ", player.position)
	else:
		print("Game: Warning: No spawn points found for peer ", peer_id, " (team ", team, ")")
	
	return player

func _spawn_ball(data):
	var ball = preload("res://Ball.tscn").instantiate()
	ball.position = data["position"]
	ball.linear_velocity = data["velocity"]
	print("Game: Spawning ball at ", data["position"])
	return ball

func player_hit(player_id: String):
	if multiplayer.is_server():
		var id = int(player_id)
		if player_lives.has(id):
			player_lives[id] -= 1
			var player_node = $Players.get_node_or_null(player_id)
			if player_node:
				player_node.update_lives.rpc(player_lives[id])
				if player_lives[id] <= 0:
					player_node.set_spectator_mode.rpc()
				else:
					player_node.respawn.rpc()

func _process(delta):
	if multiplayer.is_server() and game_active:
		time_since_last_sync += delta
		if time_since_last_sync >= sync_interval:
			timer_sync.time_left = game_timer.time_left
			time_since_last_sync = 0.0
