extends Node3D

@onready var multiplayer_spawner = $Players/MultiplayerSpawner
@onready var ball_spawner = $Balls/BallSpawner

var team_assignments = {}  # peer_id -> team (0 for Team A, 1 for Team B)

func _ready():
	multiplayer_spawner.spawn_function = _spawn_player
	ball_spawner.spawn_function = _spawn_ball
	# Ensure spawners are server-authoritative
	multiplayer_spawner.set_multiplayer_authority(1)
	ball_spawner.set_multiplayer_authority(1)
	if multiplayer.is_server():
		team_assignments[multiplayer.get_unique_id()] = 0
		var host_data = {"peer_id": multiplayer.get_unique_id(), "team": 0}
		print("InGame: Spawning host with data: ", host_data)
		multiplayer_spawner.spawn(host_data)

	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)

func _on_peer_connected(id):
	if multiplayer.is_server():
		await get_tree().create_timer(0.5).timeout
		team_assignments[id] = 1
		var client_data = {"peer_id": id, "team": 1}
		print("InGame: Spawning client with data: ", client_data)
		multiplayer_spawner.spawn(client_data)

func _on_peer_disconnected(id):
	if $Players.has_node(str(id)):
		$Players.get_node(str(id)).queue_free()
	team_assignments.erase(id)
	print("InGame: Peer disconnected: ", id)

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
		print("InGame: Spawned player ", peer_id, " (team ", team, ") at ", player.position)
	else:
		print("InGame: Warning: No spawn points found for team ", team, " for peer ", peer_id)
	return player

func _spawn_ball(data):
	var ball = preload("res://Ball.tscn").instantiate()
	ball.position = data["position"]
	ball.linear_velocity = data["velocity"]
	print("InGame: Spawning ball at ", data["position"])
	return ball
