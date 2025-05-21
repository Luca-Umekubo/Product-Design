extends Node3D

@onready var multiplayer_spawner = $Players/MultiplayerSpawner
@onready var ball_spawner = $Balls/BallSpawner
@onready var start_button = $Control/Button

var team_assignments = {}  # peer_id -> team (0 for Team A, 1 for Team B)
var peers_ready = {}      # Track peers that are ready to change scenes

func _ready():
	multiplayer_spawner.spawn_function = _spawn_player
	ball_spawner.spawn_function = _spawn_ball
	# Ensure spawners are server-authoritative
	multiplayer_spawner.set_multiplayer_authority(1)
	ball_spawner.set_multiplayer_authority(1)
	start_button.visible = multiplayer.is_server()
	
	if multiplayer.is_server():
		# Spawn all connected peers, including the host, with balanced teams
		var peer_ids = multiplayer.get_peers()
		peer_ids.append(multiplayer.get_unique_id())  # Include the server itself
		var team_a_count = 0
		var team_b_count = 0
		for i in peer_ids.size():
			var peer_id = peer_ids[i]
			# Assign to team with fewer players
			var team = 0 if team_a_count <= team_b_count else 1
			team_assignments[peer_id] = team
			if team == 0:
				team_a_count += 1
			else:
				team_b_count += 1
			var player_data = {"peer_id": peer_id, "team": team}
			print("Lobby: Spawning player with data: ", player_data)
			multiplayer_spawner.spawn(player_data)

	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)

func _on_peer_connected(id):
	if multiplayer.is_server():
		# Handle peers that connect after the game has started
		await get_tree().create_timer(0.5).timeout
		# Assign to team with fewer players
		var team_a_count = team_assignments.values().count(0)
		var team_b_count = team_assignments.values().count(1)
		var team = 0 if team_a_count <= team_b_count else 1
		team_assignments[id] = team
		var client_data = {"peer_id": id, "team": team}
		print("Lobby: Spawning client with data: ", client_data)
		multiplayer_spawner.spawn(client_data)

func _on_peer_disconnected(id):
	if $Players.has_node(str(id)):
		$Players.get_node(str(id)).queue_free()
	team_assignments.erase(id)
	peers_ready.erase(id)
	print("Lobby: Peer disconnected: ", id)

func _spawn_player(data):
	var peer_id = data["peer_id"]
	var team = data["team"]
	var player = preload("res://Player.tscn").instantiate()
	player.name = str(peer_id)
	player.set_multiplayer_authority(peer_id)
	player.team = team  # Set the team property on the player
	var spawn_points = get_tree().get_nodes_in_group("TeamASpawnPoints" if team == 0 else "TeamBSpawnPoints")
	if spawn_points.size() > 0:
		var spawn_point = spawn_points[randi() % spawn_points.size()]
		player.position = spawn_point.global_position
		print("Lobby: Spawned player ", peer_id, " (team ", team, ") at ", player.position)
	else:
		print("Lobby: Warning: No spawn points found for team ", team, " for peer ", peer_id)
	return player

func _spawn_ball(data):
	var ball = preload("res://Ball.tscn").instantiate()
	ball.position = data["position"]
	ball.linear_velocity = data["velocity"]
	
	# Apply team color if team is specified
	if data.has("team") and data.team != null:
		# This will be called after _ready, so we need to defer it
		ball.call_deferred("apply_team_color", data.team)
	
	print("Lobby: Spawning ball at ", data["position"])
	return ball

func _on_start_button_pressed():
	if multiplayer.is_server():
		print("Game: Start button pressed, preparing transition")
		# First, inform all clients to prepare for scene change
		prepare_for_scene_change.rpc()

@rpc("authority", "call_local")
func prepare_for_scene_change():
	# Clients should acknowledge they're ready
	if not multiplayer.is_server():
		# Client cleanup steps before scene change
		for child in $Players.get_children():
			if child.has_method("set_physics_process"):
				child.set_physics_process(false)
				
		for ball in get_tree().get_nodes_in_group("balls"):
			if is_instance_valid(ball):
				ball.queue_free()
				
		# Let the server know this client is ready
		client_ready_for_scene_change.rpc_id(1)
	else:
		# Server also processes locally
		peers_ready[multiplayer.get_unique_id()] = true
		check_all_peers_ready()

@rpc("any_peer")
func client_ready_for_scene_change():
	if not multiplayer.is_server():
		return
		
	var sender_id = multiplayer.get_remote_sender_id()
	peers_ready[sender_id] = true
	check_all_peers_ready()

func check_all_peers_ready():
	if not multiplayer.is_server():
		return
		
	# Check if all peers are ready
	var all_peers = multiplayer.get_peers()
	all_peers.append(multiplayer.get_unique_id())
	
	var all_ready = true
	for peer_id in all_peers:
		if not peers_ready.has(peer_id) or not peers_ready[peer_id]:
			all_ready = false
			break
	
	if all_ready:
		print("All peers ready, changing scene...")
		# Clean up all players and balls server-side first
		for child in $Players.get_children():
			child.queue_free()
			
		for ball in get_tree().get_nodes_in_group("balls"):
			if is_instance_valid(ball):
				ball.queue_free()
		
		# Wait a frame for cleanup to process
		await get_tree().process_frame
		
		# Now change the scene
		change_to_ingame_scene.rpc()

@rpc("authority", "call_local")
func change_to_ingame_scene():
	# This will be called on all peers after cleanup
	get_tree().change_scene_to_file("res://Game.tscn")
