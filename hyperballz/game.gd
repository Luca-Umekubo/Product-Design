extends Node3D

@onready var multiplayer_spawner = $Players/MultiplayerSpawner
@onready var ball_spawner = $Balls/BallSpawner
@onready var game_timer = $GameTimer

var game_active = false

func _ready():
	multiplayer_spawner.spawn_function = _spawn_player
	ball_spawner.spawn_function = _spawn_ball
	if multiplayer.is_server():
		# Spawn the host's player immediately
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
	# Spawn player for newly connected clients
	multiplayer_spawner.spawn({"peer_id": id})
	# NEW: Sync timer state with new clients
	if multiplayer.is_server() and game_active:
		update_timer_display.rpc_id(id, game_timer.time_left)

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
