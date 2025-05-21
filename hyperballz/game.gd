extends Node3D

@onready var multiplayer_spawner = $Players/MultiplayerSpawner
@onready var ball_spawner = $Balls/BallSpawner
@onready var game_timer = $GameTimer
@onready var timer_sync = $TimerSync
var sync_interval = 0.5  # Update every 0.5 seconds
var time_since_last_sync = 0.0
var player_lives = {}  # Tracks lives for each player (peer_id: lives)
var team_assignments = {}  # Tracks team for each player (peer_id: team)

# Array of initial ball positions
var initial_ball_positions = [
	Vector3(20, 1, 18),
	Vector3(20, 1, 12),
	Vector3(20, 1, 6),
	Vector3(20, 1, 0),
	Vector3(20, 1, -6),
	Vector3(20, 1, -12),
	Vector3(20, 1, -18)
]

var game_active = false

func _ready():
	multiplayer_spawner.spawn_function = _spawn_player
	ball_spawner.spawn_function = _spawn_ball
	multiplayer_spawner.set_multiplayer_authority(1)
	ball_spawner.set_multiplayer_authority(1)
	
	if multiplayer.is_server():
		var peer_ids = multiplayer.get_peers()
		peer_ids.append(multiplayer.get_unique_id())  # Include the server itself
		
		# Get spawn points for each team
		var team_a_spawns = get_tree().get_nodes_in_group("TeamASpawnPoints")
		var team_b_spawns = get_tree().get_nodes_in_group("TeamBSpawnPoints")
		
		# Debug prints for available spawn points
		print("Team A spawn points: ", team_a_spawns.map(func(spawn): return spawn.global_position))
		print("Team B spawn points: ", team_b_spawns.map(func(spawn): return spawn.global_position))
		
		# Arrays to track available spawn points
		var available_team_a_spawns = team_a_spawns.duplicate()
		var available_team_b_spawns = team_b_spawns.duplicate()
		
		var team_a_count = 0
		var team_b_count = 0
		
		for peer_id in peer_ids:
			var team = 0 if peer_id == multiplayer.get_unique_id() else 1
			#team_assignments[peer_id] = team
			player_lives[peer_id] = 2
			
			var spawn_points = available_team_a_spawns if team == 0 else available_team_b_spawns
			
			var spawn_pos
			if spawn_points.size() > 0:
				# Take the first available spawn point and remove it from the list
				var spawn_point = spawn_points.pop_front()
				spawn_pos = spawn_point.global_position
			else:
				# If no spawn points are left, use a default position with an offset
				print("Warning: No more spawn points available for team ", team, " for player ", peer_id)
				spawn_pos = Vector3.ZERO + Vector3(randf_range(-2, 2), 0, randf_range(-2, 2)) * (team_a_count + team_b_count)
			
			var player_data = {"peer_id": peer_id, "team": team, "spawn_pos": spawn_pos}
			print("InGame: Spawning player with data: ", player_data)
			multiplayer_spawner.spawn(player_data)
			
			if team == 0:
				team_a_count += 1
			else:
				team_b_count += 1
		
		# Spawn initial dodgeballs
		for pos in initial_ball_positions:
			var ball_data = {"position": pos, "velocity": Vector3.ZERO}
			ball_spawner.spawn(ball_data)
			print("Spawning initial ball at ", pos)
		
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
		var team_a_count = team_assignments.values().count(0)
		var team_b_count = team_assignments.values().count(1)
		var team = 0 if team_a_count <= team_b_count else 1
		team_assignments[id] = team
		player_lives[id] = 2
		var spawn_points = get_tree().get_nodes_in_group("TeamASpawnPoints" if team == 0 else "TeamBSpawnPoints")
		var spawn_pos
		if spawn_points.size() > 0:
			var spawn_point = spawn_points[randi() % spawn_points.size()]
			spawn_pos = spawn_point.global_position
		else:
			spawn_pos = Vector3.ZERO
		var client_data = {"peer_id": id, "team": team, "spawn_pos": spawn_pos}
		print("Game: Spawning client with data: ", client_data)
		multiplayer_spawner.spawn(client_data)
		if game_active:
			update_timer_display.rpc_id(id, game_timer.time_left)

func _on_peer_disconnected(id):
	if multiplayer.is_server():
		if $Players.has_node(str(id)):
			$Players.get_node(str(id)).queue_free()
		player_lives.erase(id)
		team_assignments.erase(id)

func _spawn_player(data):
	var peer_id = data["peer_id"]
	var team = data["team"]
	var spawn_pos = data["spawn_pos"]
	var player = preload("res://Player.tscn").instantiate()
	player.name = str(peer_id)
	player.set_multiplayer_authority(peer_id)
	player.team = team
	player.position = spawn_pos
	print("Game: Spawned player ", peer_id, " (team ", team, ") at ", player.position)
	return player

func _spawn_ball(data):
	var ball = preload("res://Ball.tscn").instantiate()
	ball.position = data["position"]
	ball.linear_velocity = data["velocity"]
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

# Added for ball pickup
@rpc("any_peer", "call_local")
func request_pickup_ball(player_name: String):
	if not multiplayer.is_server():
		return
	var player_node = $Players.get_node_or_null(player_name)
	if player_node and not player_node.has_ball:
		var space_state = player_node.get_world_3d().direct_space_state
		var query = PhysicsShapeQueryParameters3D.new()
		var shape = SphereShape3D.new()
		shape.radius = 2.0
		query.shape = shape
		query.transform = player_node.global_transform
		query.exclude = [player_node]
		var results = space_state.intersect_shape(query)
		var closest_ball = null
		var min_distance = INF
		for result in results:
			var collider = result.collider
			if collider.is_in_group("balls"):
				var distance = player_node.global_position.distance_to(collider.global_position)
				if distance < min_distance:
					min_distance = distance
					closest_ball = collider
		if closest_ball:
			closest_ball.queue_free()
			player_node.set_has_ball(true)

func _input(event):
	# Check if the event is a key press and the key is "Esc"
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		# Change to the EscapeMenu scene
		get_tree().change_scene_to_file("res://EscapeMenu.tscn")
