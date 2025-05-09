extends Node3D

@onready var multiplayer_spawner = $Players/MultiplayerSpawner
@onready var ball_spawner = $Balls/BallSpawner

func _ready():
	multiplayer_spawner.spawn_function = _spawn_player
	ball_spawner.spawn_function = _spawn_ball
	if multiplayer.is_server():
		# Spawn the host's player immediately
		multiplayer_spawner.spawn({"peer_id": multiplayer.get_unique_id()})

	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)

func _on_peer_connected(id):
	# Spawn player for newly connected clients
	multiplayer_spawner.spawn({"peer_id": id})

func _on_peer_disconnected(id):
	# Remove player when a client disconnects
	if $Players.has_node(str(id)):
		$Players.get_node(str(id)).queue_free()

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
