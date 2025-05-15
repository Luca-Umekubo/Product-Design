extends Node3D

@onready var multiplayer_spawner = $Players/MultiplayerSpawner
@onready var ball_spawner = $Balls/BallSpawner
@onready var start_button = $Control/Button

var team_assignments = {}  # peer_id -> team (0 for Team A, 1 for Team B)

func _ready():
	multiplayer_spawner.spawn_function = _spawn_player
	ball_spawner.spawn_function = _spawn_ball
	# Ensure spawners are server-authoritative
	multiplayer_spawner.set_multiplayer_authority(1)
	ball_spawner.set_multiplayer_authority(1)
	start_button.visible = multiplayer.is_server()
	
	if multiplayer.is_server():
		# Spawn all connected peers, including the host
		var peer_ids = multiplayer.get_peers()
		peer_ids.append(multiplayer.get_unique_id())  # Include the server itself
		for i in peer_ids.size():
			var peer_id = peer_ids[i]
			# Assign teams (e.g., host to Team A, others to Team B)
			var team = 0 if peer_id == multiplayer.get_unique_id() else 1
			team_assignments[peer_id] = team
			var player_data = {"peer_id": peer_id, "team": team}
			print("Lobby: Spawning player with data: ", player_data)
			multiplayer_spawner.spawn(player_data)

	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)

func _on_peer_connected(id):
	if multiplayer.is_server():
		# Handle peers that connect after the game has started
		await get_tree().create_timer(0.5).timeout
		team_assignments[id] = 1
		var client_data = {"peer_id": id, "team": 1}
		print("Lobby: Spawning client with data: ", client_data)
		multiplayer_spawner.spawn(client_data)

func _on_peer_disconnected(id):
	if $Players.has_node(str(id)):
		$Players.get_node(str(id)).queue_free()
	team_assignments.erase(id)
	print("Lobby: Peer disconnected: ", id)

func _spawn_player(data):
	var peer_id = data["peer_id"]
	var team = data["team"]
	var player = preload("res://Player.tscn").instantiate()
	player.name = str(peer_id)
	player.set_multiplayer_authority(peer_id)
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
	print("Lobby: Spawning ball at ", data["position"])
	return ball


func _on_start_button_pressed():
	if multiplayer.is_server():
		print("Game: Start button pressed, changing to Game")
		change_to_ingame_scene.rpc()

@rpc("authority", "call_local")
func change_to_ingame_scene():
	get_tree().change_scene_to_file("res://Game.tscn")
