extends Node3D

@onready var multiplayer_spawner = $Players/MultiplayerSpawner
@onready var ball_spawner = $Balls/BallSpawner
@onready var game_timer = $GameTimer
@onready var timer_sync = $TimerSync
var sync_interval = 0.5  # Update every 0.5 seconds
var time_since_last_sync = 0.0
var player_lives = {}  # Tracks lives for each player (peer_id: lives)
var game_active = false
var gravity_halved = false  # Flag to ensure gravity is halved only once

func _ready():
	multiplayer_spawner.spawn_function = _spawn_player
	ball_spawner.spawn_function = _spawn_ball
	multiplayer_spawner.set_multiplayer_authority(1)
	ball_spawner.set_multiplayer_authority(1)
	
	if multiplayer.is_server():
		var peer_ids = multiplayer.get_peers()
		peer_ids.append(multiplayer.get_unique_id())  # Include the server itself
		for peer_id in peer_ids:
			var team = 0 if peer_id == multiplayer.get_unique_id() else 1
			player_lives[peer_id] = 2
			var player_data = {"peer_id": peer_id, "team": team}
			print("InGame: Spawning player with data: ", player_data)
			multiplayer_spawner.spawn(player_data)
		
		game_timer.wait_time = 300.0
		game_timer.one_shot = true
		game_timer.timeout.connect(_on_game_timer_timeout)
		start_game_timer()
	
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)

func start_game_timer():
	if multiplayer.is_server() and not game_active:
		game_active = true
		game_timer.start()
		update_timer_display.rpc(game_timer.wait_time)

@rpc("authority", "call_local")
func update_timer_display(time_left):
	pass

func _on_game_timer_timeout():
	if multiplayer.is_server():
		game_active = false
		end_game.rpc()

@rpc("authority", "call_local")
func end_game():
	get_tree().change_scene_to_file("res://HomeScreen.tscn")

func _on_peer_connected(id):
	if multiplayer.is_server():
		await get_tree().create_timer(0.5).timeout
		var client_data = {"peer_id": id}
		print("Game: Spawning client with data: ", client_data)
		multiplayer_spawner.spawn(client_data)
		player_lives[id] = 2
	if multiplayer.is_server() and game_active:
		update_timer_display.rpc_id(id, game_timer.time_left)

func _on_peer_disconnected(id):
	if multiplayer.is_server():
		if $Players.has_node(str(id)):
			$Players.get_node(str(id)).queue_free()
		player_lives.erase(id)

func _spawn_player(data):
	var peer_id = data["peer_id"]
	var player = preload("res://Player.tscn").instantiate()
	player.name = str(peer_id)
	player.set_multiplayer_authority(peer_id)
	var spawn_points = get_tree().get_nodes_in_group("spawn_points")
	if spawn_points.size() > 0:
		var spawn_point = spawn_points[randi() % spawn_points.size()]
		player.position = spawn_point.global_position
		print("Game: Spawned player ", peer_id, " at ", player.position)
	else:
		print("Game: Warning: No spawn points found for peer ", peer_id)
	return player

func _spawn_ball(data):
	var ball = preload("res://Ball.tscn").instantiate()
	ball.position = data["position"]
	ball.linear_velocity = data["velocity"]
	ball.gravity_scale = GameState.gravity_multiplier  # Set gravity_scale at spawn
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
		# Check if 30 seconds remain and gravity hasn't been halved yet
		if not gravity_halved and game_timer.time_left <= 30.0:
			gravity_halved = true
			set_gravity_multiplier.rpc(0.5)  # Notify all clients to halve gravity

@rpc("authority", "call_local")
func set_gravity_multiplier(multiplier: float):
	GameState.gravity_multiplier = multiplier  # Update the global state
