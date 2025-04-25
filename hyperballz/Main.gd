extends Node3D

const Player = preload("res://Player.tscn")
const Ball = preload("res://Ball.tscn")

@export var is_server: bool = true
@export var server_ip: String = "127.0.0.1"

var ball_counter: int = 0
var balls: Dictionary = {} # Tracks balls {ball_id: {node, position, velocity}}
var spawn_points: Array = [] # Array to hold spawn point nodes

func _ready():
	var peer = ENetMultiplayerPeer.new()
	if is_server:
		peer.create_server(4242, 32)
	else:
		peer.create_client(server_ip, 4242)
	multiplayer.multiplayer_peer = peer

	var id = multiplayer.get_unique_id()
	spawn_player(id)

	multiplayer.peer_connected.connect(_player_connected)
	if is_server:
		# Sync balls every 0.05 seconds (20 Hz)
		var timer = Timer.new()
		timer.wait_time = 0.05
		timer.autostart = true
		timer.timeout.connect(_sync_balls)
		add_child(timer)
	
	# Retrieve spawn points from the scene
	spawn_points = get_tree().get_nodes_in_group("spawn_points")

func spawn_player(id):
	var player = Player.instantiate()
	player.name = str(id)
	player.set_multiplayer_authority(id)
	add_child(player)
	# Set player position to a random spawn point
	if spawn_points.size() > 0:
		var spawn_point = spawn_points[randi() % spawn_points.size()]
		player.global_position = spawn_point.global_position
	else:
		print("Warning: No spawn points defined in the scene!")

func _player_connected(id):
	spawn_player(id)

@rpc("any_peer", "call_local")
func request_spawn_ball(position, velocity):
	if is_server:
		ball_counter += 1
		var ball_id = ball_counter
		var ball = Ball.instantiate()
		ball.name = "Ball_" + str(ball_id)
		ball.global_position = position
		ball.linear_velocity = velocity
		ball.set_multiplayer_authority(1) # Server controls ball
		add_child(ball)
		balls[ball_id] = {"node": ball, "position": position, "velocity": velocity}
		rpc("spawn_ball_client", ball_id, position, velocity)

@rpc("any_peer", "call_local")
func spawn_ball_client(ball_id, position, velocity):
	if not is_server: # Clients only render, don't simulate physics
		var ball = Ball.instantiate()
		ball.name = "Ball_" + str(ball_id)
		ball.global_position = position
		ball.linear_velocity = velocity
		ball.freeze = true # Disable physics on clients
		add_child(ball)
		balls[ball_id] = {"node": ball, "position": position, "velocity": velocity}

@rpc("reliable")
func sync_ball_state(ball_id, position, velocity):
	if not is_server and balls.has(ball_id):
		var ball = balls[ball_id]["node"]
		ball.global_position = position
		ball.linear_velocity = velocity

func _sync_balls():
	if is_server:
		for ball_id in balls.keys():
			var ball = balls[ball_id]["node"]
			if is_instance_valid(ball):
				var position = ball.global_position
				var velocity = ball.linear_velocity
				balls[ball_id]["position"] = position
				balls[ball_id]["velocity"] = velocity
				rpc("sync_ball_state", ball_id, position, velocity)
			else:
				balls.erase(ball_id)
				rpc("remove_ball", ball_id)

@rpc("reliable")
func remove_ball(ball_id):
	if balls.has(ball_id):
		var ball = balls[ball_id]["node"]
		if is_instance_valid(ball):
			ball.queue_free()
		balls.erase(ball_id)
