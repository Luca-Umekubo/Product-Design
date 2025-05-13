extends Node3D

@onready var multiplayer_spawner = $Players/MultiplayerSpawner
@onready var ball_spawner = $Balls/BallSpawner
@onready var start_button = $CanvasLayer/StartButton

func _ready():
	multiplayer_spawner.spawn_function = _spawn_player
	ball_spawner.spawn_function = _spawn_ball
	start_button.visible = multiplayer.is_server()
	if multiplayer.is_server():
		if not start_button.pressed.is_connected(_on_start_button_pressed):
			start_button.pressed.connect(_on_start_button_pressed)
		# Spawn host
		var host_data = {"peer_id": multiplayer.get_unique_id()}
		print("Game: Spawning host with data: ", host_data)
		multiplayer_spawner.spawn(host_data)

	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)

func _on_peer_connected(id):
	if multiplayer.is_server():
		# Delay spawn to ensure peer is fully connected
		await get_tree().create_timer(0.5).timeout
		var client_data = {"peer_id": id}
		print("Game: Spawning client with data: ", client_data)
		multiplayer_spawner.spawn(client_data)

func _on_peer_disconnected(id):
	if $Players.has_node(str(id)):
		$Players.get_node(str(id)).queue_free()
	print("Game: Peer disconnected: ", id)

func _spawn_player(data):
	var peer_id = data["peer_id"]
	var player = preload("res://Player.tscn").instantiate()
	player.name = str(peer_id)
	player.set_multiplayer_authority(peer_id)
	# Random spawn point for Game.tscn
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
	print("Game: Spawning ball at ", data["position"])
	return ball

func _on_start_button_pressed():
	if multiplayer.is_server():
		print("Game: Start button pressed, changing to InGame")
		change_to_ingame_scene.rpc()

@rpc("authority", "call_local")
func change_to_ingame_scene():
	get_tree().change_scene_to_file("res://InGame.tscn")
