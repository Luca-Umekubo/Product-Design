# ingame.gd
extends Node3D

@onready var multiplayer_spawner = $Players/MultiplayerSpawner
@onready var spectator_spawner = $Spectators/MultiplayerSpawner
@onready var ball_spawner = $Balls/BallSpawner

func _ready():
	# Set up the spawn function
	multiplayer_spawner.spawn_function = _spawn_player
	# Spawn all connected peers, including the host
	for peer_id in multiplayer.get_peers():
		multiplayer_spawner.spawn({"peer_id": peer_id})
	if multiplayer.is_server():
		multiplayer_spawner.spawn({"peer_id": multiplayer.get_unique_id()})

func _spawn_player(data):
	var peer_id = data["peer_id"]
	if peer_id in Network.player_peers:
		# Spawn as a regular player if they were present at the start
		var player = preload("res://Player.tscn").instantiate()
		player.name = str(peer_id)
		player.set_multiplayer_authority(peer_id)
		return player
	else:
		# Spawn as a spectator if they joined after the start
		var spectator = preload("res://Spectator.tscn").instantiate()
		spectator.name = "Spectator_" + str(peer_id)
		spectator.set_multiplayer_authority(peer_id)
		return spectator

func _on_peer_connected(id):
	# Spawn player for newly connected clients
	if id in Network.player_peers:
		multiplayer_spawner.spawn({"peer_id": id})
	else:
		spectator_spawner.spawn({"peer_id": id})
	# Spectators are spawned for players who join after the game starts
	

func _on_peer_disconnected(id):
	# Remove player when a client disconnects
	if $Players.has_node(str(id)):
		$Players.get_node(str(id)).queue_free()
	elif $Spectators.has_node("Spectator_" + str(id)):
		$Spectators.get_node("Spectator_" + str(id)).queue_free()
