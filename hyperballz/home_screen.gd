extends Control

func _on_host_pressed():
	Network.start_server(1234, 10)  # Port 1234, max 10 clients
	get_tree().change_scene_to_file("res://Game.tscn")

func _on_join_pressed():
	get_tree().change_scene_to_file("res://LobbySelector.tscn")
