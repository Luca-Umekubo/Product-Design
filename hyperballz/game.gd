extends Node3D

@onready var multiplayer_spawner = $Players/MultiplayerSpawner
@onready var ball_spawner = $Balls/BallSpawner
var player_lives = {}  # Tracks lives for each player (peer_id: lives)

func _ready():
	multiplayer_spawner.spawn_function = _spawn_player
	ball_spawner.spawn_function = _spawn_ball
	if multiplayer.is_server():
		# Initialize lives for the host
		player_lives[multiplayer.get_unique_id()] = 2
		multiplayer_spawner.spawn({"peer_id": multiplayer.get_unique_id()})

	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)

func _on_peer_connected(id):
	if multiplayer.is_server():
		# Initialize lives for new player
		player_lives[id] = 2
		multiplayer_spawner.spawn({"peer_id": id})

func _on_peer_disconnected(id):
	if multiplayer.is_server():
		# Remove player and lives entry
		if $Players.has_node(str(id)):
			$Players.get_node(str(id)).queue_free()
		player_lives.erase(id)

func _spawn_player(data):
	var player = preload("res://Player.tscn").instantiate()
	player.name = str(data["peer_id"])
	player.set_multiplayer_authority(data["peer_id"])
	return player

func _spawn_ball(data):
	var ball = preload("res://Ball.tscn").instantiate()
	ball.position = data["position"]
	ball.linear_velocity = data["velocity"]
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
