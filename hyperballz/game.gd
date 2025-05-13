extends Node3D

@onready var multiplayer_spawner = $Players/MultiplayerSpawner
@onready var ball_spawner = $Balls/BallSpawner
@onready var game_timer = $GameTimer
@onready var timer_sync = $TimerSync
var sync_interval = 0.5  # Update every 0.5 seconds
var time_since_last_sync = 0.0
var player_lives = {}  # Tracks lives for each player (peer_id: lives)

var game_active = false

func _ready():
	multiplayer_spawner.spawn_function = _spawn_player
	ball_spawner.spawn_function = _spawn_ball
	if multiplayer.is_server():
		# Initialize lives for the host
		player_lives[multiplayer.get_unique_id()] = 2
		multiplayer_spawner.spawn({"peer_id": multiplayer.get_unique_id()})
		# Set up timer
		game_timer.wait_time = 300.0
		game_timer.one_shot = true
		game_timer.timeout.connect(_on_game_timer_timeout)
		# Start the timer for testing
		start_game_timer()

	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)

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
		# Initialize lives for new player
		player_lives[id] = 2
		multiplayer_spawner.spawn({"peer_id": id})
	if multiplayer.is_server() and game_active:
		update_timer_display.rpc_id(id, game_timer.time_left)

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

func _process(delta):
	if multiplayer.is_server() and game_active:
		time_since_last_sync += delta
		if time_since_last_sync >= sync_interval:
			timer_sync.time_left = game_timer.time_left
			time_since_last_sync = 0.0
