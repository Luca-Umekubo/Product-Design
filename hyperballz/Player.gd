extends CharacterBody3D

@onready var camera = $Camera3D
var speed = 5.0
var mouse_sensitivity = 0.005
var gravity = -9.8
var jump_strength = 4.5
var is_mouse_captured = true

func _ready():
	add_to_group("players")
	if is_multiplayer_authority():
		camera.make_current()
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		is_mouse_captured = true
		print("Player ", name, " authority: ", get_multiplayer_authority(), " camera active: ", camera.is_current())
	else:
		camera.current = false
		print("Player ", name, " non-authoritative, camera disabled")

func _input(event):
	if is_multiplayer_authority():
		if event is InputEventKey and event.is_action_pressed("ui_cancel"):
			if is_mouse_captured:
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
				is_mouse_captured = false
			else:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
				is_mouse_captured = true
		if is_mouse_captured and event is InputEventMouseMotion:
			rotate_y(-event.relative.x * mouse_sensitivity)
			camera.rotate_x(-event.relative.y * mouse_sensitivity)
			camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)

func _physics_process(delta):
	if is_multiplayer_authority():
		var input_vector = Vector2(
			Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
			Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")
		).normalized()

		var move_direction = Vector3(input_vector.x, 0, input_vector.y) * speed
		move_direction = global_transform.basis * move_direction
		
		velocity.x = move_direction.x
		velocity.z = move_direction.z
		velocity.y += gravity * delta
		
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = jump_strength
			print("غه:Player ", name, " jumped at ", global_position)

		move_and_slide()

		if Input.is_action_just_pressed("throw"):
			throw_ball.rpc()

@rpc("any_peer", "call_local")
func throw_ball():
	if not multiplayer.is_server():
		return
	var spawn_position = $Camera3D/BallSpawnPoint.global_position
	var spawn_velocity = $Camera3D.global_transform.basis.z * -10
	var ball_data = {
		"position": spawn_position,
		"velocity": spawn_velocity
	}
	var root = get_tree().get_root()
	var ball_spawner_path = "Game/Balls/BallSpawner" if root.has_node("Game") else "InGame/Balls/BallSpawner"
	root.get_node(ball_spawner_path).spawn(ball_data)

@rpc("authority")
func respawn():
	if is_multiplayer_authority():
		var team = 0
		if get_tree().get_root().has_node("InGame"):
			var in_game = get_tree().get_root().get_node("InGame")
			if in_game.team_assignments.has(multiplayer.get_unique_id()):
				team = in_game.team_assignments[multiplayer.get_unique_id()]
		var spawn_points = get_tree().get_nodes_in_group("TeamASpawnPoints" if team == 0 else "TeamBSpawnPoints")
		if spawn_points.size() > 0:
			var spawn_point = spawn_points[randi() % spawn_points.size()]
			global_position = spawn_point.global_position
			print("Player ", name, " respawned at ", global_position)
		else:
			spawn_points = get_tree().get_nodes_in_group("spawn_points")
			if spawn_points.size() > 0:
				var spawn_point = spawn_points[randi() % spawn_points.size()]
				global_position = spawn_point.global_position
				print("Player ", name, " respawned (fallback) at ", global_position)
			else:
				print("Warning: No spawn points found for player ", name)
