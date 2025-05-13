#home_screen.gd

extends Control

func _on_host_pressed():
	Network.start_server(4242, 10)  # Port 4242, max 10 clients
	get_tree().change_scene_to_file("res://Pregame.tscn")

func _on_join_pressed():
	get_tree().change_scene_to_file("res://LobbySelector.tscn")
