extends Node3D

const Player = preload("res://Player.tscn")
const Ball   = preload("res://Ball.tscn")

@export var is_server: bool   = true
@export var server_ip: String = "127.0.0.1"

var ball_counter: int         = 0
var balls: Dictionary         = {}  # Tracks balls { ball_id: { node, position, velocity } }
var spawn_points: Array       = []  # Will hold all your spawn point nodes

func _ready():
	var peer = ENetMultiplayerPeer.new()
	if is_server:
		peer.create_server(4242, 32)
	else:
		peer.create_client(server_ip, 4242)
	multiplayer.multiplayer_peer = peer

	# Immediately spawn ourselves
	var id = multiplayer.get_unique_id()
	spawn_player(id)

	multiplayer.peer_connected.connect(_player_connected)

	if is_server:
		# Sync balls 20×/sec
		var timer = Timer.new()
		timer.wait_time = 0.05
		timer.autostart = true
		timer.timeout.connect(_sync_balls)
		add_child(timer)

	# Gather all spawn‐point nodes in the scene
	spawn_points = get_tree().get_nodes_in_group("spawn_points")


func spawn_player(id):
	var player = Player.instantiate()
	player.name = str(id)
	player.set_multiplayer_authority(id)
	add_child(player)
	player.add_to_group("players")    # ← NEW: track players in a group

	# Place at a random spawn point
	if spawn_points.size() > 0:
		var sp = spawn_points[randi() % spawn_points.size()]
		player.global_position = sp.global_position
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
		ball.set_multiplayer_authority(1)  # Server controls physics
		add_child(ball)
		balls[ball_id] = {"node": ball, "position": position, "velocity": velocity}
		# Let all clients render this new ball
		rpc("spawn_ball_client", ball_id, position, velocity)


func spawn_ball_client(ball_id, position, velocity):
	if not is_server:
		var ball = Ball.instantiate()
		ball.name = "Ball_" + str(ball_id)
		ball.global_position = position
		ball.linear_velocity = velocity
		ball.freeze = true   # Disable client‐side physics
		add_child(ball)
		balls[ball_id] = {"node": ball, "position": position, "velocity": velocity}


@rpc("reliable")
func sync_ball_state(ball_id, position, velocity):
	if not is_server and balls.has(ball_id):
		var ball = balls[ball_id]["node"]
		ball.global_position = position


func _sync_balls():
	if is_server:
		for ball_id in balls.keys():
			var ball = balls[ball_id]["node"]
			if not is_instance_valid(ball):
				balls.erase(ball_id)
				rpc("remove_ball", ball_id)
				continue

			# 1) Update stored position/velocity
			var pos = ball.global_position
			var vel = ball.linear_velocity
			balls[ball_id]["position"] = pos
			balls[ball_id]["velocity"] = vel

			# 2) Check for hits on any player
			for player in get_tree().get_nodes_in_group("players"):
				if pos.distance_to(player.global_position) < 1.0:
					_respawn_player(player)
					ball.queue_free()
					balls.erase(ball_id)
					rpc("remove_ball", ball_id)
					break

			# 3) Broadcast updated state if still alive
			if balls.has(ball_id):
				rpc("sync_ball_state", ball_id, pos, vel)


func _respawn_player(player):
	if spawn_points.size() == 0:
		push_warning("No spawn points defined to respawn!")
		return

	# Teleport to a random spawn point
	var sp = spawn_points[randi() % spawn_points.size()]
	player.global_position = sp.global_position

	# Ensure the client updates its visible position immediately
	player.rpc("update_puppet_transform", player.global_transform)


@rpc("reliable")
func remove_ball(ball_id):
	if balls.has(ball_id):
		var ball = balls[ball_id]["node"]
		if is_instance_valid(ball):
			ball.queue_free()
		balls.erase(ball_id)
