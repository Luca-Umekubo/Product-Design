extends Node3D

@onready var multiplayer_spawner = $Players/MultiplayerSpawner
@onready var ball_spawner = $Balls/BallSpawner
@onready var start_button = $UI/StartButton

func _ready():
	multiplayer_spawner.spawn_function = _spawn_player
	ball_spawner.spawn_function = _spawn_ball
	if multiplayer.is_server():
		# Spawn the host's player immediately
		multiplayer_spawner.spawn({"peer_id": multiplayer.get_unique_id()})
		start_button.show()  # Always show UI for the host
	else:
		start_button.hide()  # Hide UI for clients

	start_button.pressed.connect(_on_start_button_pressed)

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

func _input(event):
	# Toggle mouse mode for the host when Escape is pressed
	if multiplayer.is_server() and event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _on_start_button_pressed():
	if multiplayer.is_server():
		start_game.rpc()

#WIP -- change the game to the correct file
@rpc("authority", "call_local")
func start_game():
	get_tree().change_scene_to_file("res://Ingame.tscn")
