extends Node3D

@export var is_server: bool = true
@export var server_ip: String = "127.0.0.1"

@onready var player_spawner: MultiplayerSpawner = $PlayerSpawner
@onready var ball_spawner: MultiplayerSpawner = $BallSpawner
@onready var spawn_points: Node = $SpawnPoints

func _ready():
	# Set up multiplayer peer
	var peer = ENetMultiplayerPeer.new()
	if is_server:
		peer.create_server(4242, 32)
	else:
		peer.create_client(server_ip, 4242)
	multiplayer.multiplayer_peer = peer

	# Connect peer signals
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)

	# Spawn local player
	if multiplayer.is_server() or not is_server:
		_spawn_player(multiplayer.get_unique_id())

func _spawn_player(id: int):
	# Instance player
	var player = player_spawner.spawn([id]) # Pass ID to spawner
	player.name = str(id)
	player.set_multiplayer_authority(id)
	
	# Set spawn position
	var points = spawn_points.get_children()
	if points.size() > 0:
		var spawn_point = points[randi() % points.size()]
		player.global_position = spawn_point.global_position
	else:
		print("Warning: No spawn points defined!")

func _on_peer_connected(id: int):
	if is_server:
		_spawn_player(id)

func _on_peer_disconnected(id: int):
	if is_server:
		var player = get_node_or_null(str(id))
		if player:
			player.queue_free()

@rpc("any_peer", "call_local", "reliable")
func request_spawn_ball(position: Vector3, velocity: Vector3):
	if is_server:
		var ball = ball_spawner.spawn([]) # Spawn ball
		ball.global_position = position
		ball.linear_velocity = velocity
		ball.set_multiplayer_authority(1) # Server controls ball
