# ingame.gd
extends Node3D

@onready var multiplayer_spawner = $Players/MultiplayerSpawner

func _ready():
	multiplayer_spawner.spawn_function = _spawn_player
	# Spawn players for all connected peers, including the host
	for peer_id in multiplayer.get_peers():
		multiplayer_spawner.spawn({"peer_id": peer_id})
	if multiplayer.is_server():
		multiplayer_spawner.spawn({"peer_id": multiplayer.get_unique_id()})

func _spawn_player(data):
	var player = preload("res://Player.tscn").instantiate()
	player.name = str(data["peer_id"])
	player.set_multiplayer_authority(data["peer_id"])
	return player
