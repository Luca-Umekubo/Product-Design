extends Control

func _on_lobby_list_pressed() -> void:
	get_tree().change_scene_to_file("res://LobbySelector.tscn")
