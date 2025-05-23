extends Node3D

@onready var multiplayer_spawner = $Players/MultiplayerSpawner
@onready var ball_spawner = $Balls/BallSpawner
@onready var game_timer = $GameTimer
@onready var timer_sync = $TimerSync
var sync_interval = 0.5  # Update every 0.5 seconds
var time_since_last_sync = 0.0
var player_lives = {}  # Tracks lives for each player (peer_id: lives)
var team_assignments = {}  # Tracks team for each player (peer_id: team)
var peers_ready = {} # Track peers that are ready to change scenes

# Preload the escape menu scene
var escape_menu_scene = preload("res://EscapeMenu.tscn")
var escape_menu = null  # Will hold the instance of the escape menu

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
var gravity_halved = false  # Flag to ensure gravity is halved only once

func _ready():
	multiplayer_spawner.spawn_function = _spawn_player
	ball_spawner.spawn_function = _spawn_ball
	multiplayer_spawner.set_multiplayer_authority(1)
	ball_spawner.set_multiplayer_authority(1)
	
	# Create and add the escape menu
	escape_menu = escape_menu_scene.instantiate()
	add_child(escape_menu)
	escape_menu.visible = false  # Hide the menu initially
	
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
		
		# Spawn initial dodgeballs
		for pos in initial_ball_positions:
			var ball_data = {"position": pos, "velocity": Vector3.ZERO}
			ball_spawner.spawn(ball_data)
			print("Spawning initial ball at ", pos)
		
		for peer_id in peer_ids:
			# Assign to team with fewer players
			var team = 0 if team_a_count <= team_b_count else 1
			team_assignments[peer_id] = team
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
			await get_tree().process_frame
			var player_node = $Players.get_node_or_null(str(peer_id))
			if player_node:
				player_node.update_lives.rpc(player_lives[peer_id])
			
			if team == 0:
				team_a_count += 1
			else:
				team_b_count += 1
		
		game_timer.wait_time = 300.0
		game_timer.one_shot = true
		game_timer.timeout.connect(_on_game_timer_timeout)
		start_game_timer()
	
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)

# Handle input for toggling the escape menu
func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		if escape_menu:
			escape_menu.visible = !escape_menu.visible  # Toggle menu visibility
			# Optional: Lock/unlock mouse if your game uses mouse input
			if escape_menu.visible:
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			else:
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func start_game_timer():
	if multiplayer.is_server() and not game_active:
		game_active = true
		game_timer.start()
		update_timer_display.rpc(game_timer.wait_time)

@rpc("authority", "call_local")
func update_timer_display(_time_left):
	pass

func _on_game_timer_timeout():
	if multiplayer.is_server():
		game_active = false
		prepare_for_scene_change.rpc()

@rpc("authority", "call_local")
func prepare_for_scene_change():
	# Clients should acknowledge they're ready
	if not multiplayer.is_server():
		# Client cleanup steps before scene change
		for child in $Players.get_children():
			if child.has_method("set_physics_process"):
				child.set_physics_process(false)
				
		for ball in get_tree().get_nodes_in_group("balls"):
			if is_instance_valid(ball):
				ball.queue_free()
				
		# Let the server know this client is ready
		client_ready_for_scene_change.rpc_id(1)
	else:
		# Server also processes locally
		peers_ready[multiplayer.get_unique_id()] = true
		check_all_peers_ready()

@rpc("any_peer")
func client_ready_for_scene_change():
	if not multiplayer.is_server():
		return
		
	var sender_id = multiplayer.get_remote_sender_id()
	peers_ready[sender_id] = true
	check_all_peers_ready()

func check_all_peers_ready():
	if not multiplayer.is_server():
		return
		
	# Check if all peers are ready
	var all_peers = multiplayer.get_peers()
	all_peers.append(multiplayer.get_unique_id())
	
	var all_ready = true
	for peer_id in all_peers:
		if not peers_ready.has(peer_id) or not peers_ready[peer_id]:
			all_ready = false
			break
	
	if all_ready:
		print("All peers ready, changing scene...")
		# Clean up all players and balls server-side first
		for child in $Players.get_children():
			child.queue_free()
			
		for ball in get_tree().get_nodes_in_group("balls"):
			if is_instance_valid(ball):
				ball.queue_free()
		
		# Wait a frame for cleanup to process
		await get_tree().process_frame
		
		# Now change the scene
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
		player_lives[id] = 2
		await get_tree().process_frame
		var player_node = $Players.get_node_or_null(str(id))
		if player_node:
			player_node.update_lives.rpc(player_lives[id])
	if multiplayer.is_server() and game_active:
		update_timer_display.rpc_id(id, game_timer.time_left)

func _on_peer_disconnected(id):
	if multiplayer.is_server():
		if $Players.has_node(str(id)):
			$Players.get_node(str(id)).queue_free()
		player_lives.erase(id)
		team_assignments.erase(id)
		peers_ready.erase(id)

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
	ball.gravity_scale = GameState.gravity_multiplier  # Set gravity_scale at spawn
	
	# Apply team color if team is specified
	if data.has("team") and data.team != null:
		# This will be called after _ready, so we need to defer it
		ball.call_deferred("apply_team_color", data.team)
		
	print("Game: Spawning ball at ", data["position"])
	return ball

func get_team_lives(team: int) -> int:
	var total_lives = 0
	for peer_id in team_assignments:
		if team_assignments[peer_id] == team:
			total_lives += player_lives.get(peer_id, 0)
	return total_lives

func player_hit(player_id: String):
	if multiplayer.is_server():
		var id = int(player_id)
		if player_lives.has(id):
			player_lives[id] -= 1
			var player_node = $Players.get_node_or_null(player_id)
			if player_node:
				print_debug(player_lives[id], "player lives")
				player_node.update_lives.rpc(player_lives[id])
				if player_lives[id] <= 0:
					player_node.despawn.rpc()
				#else:
					#player_node.respawn.rpc()
			var team = team_assignments[id]
			if get_team_lives(team) <= 0:
				game_active = false
				prepare_for_scene_change.rpc()	

func _process(_delta):
	if multiplayer.is_server() and game_active:
		time_since_last_sync += _delta
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
