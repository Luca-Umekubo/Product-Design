extends Control

signal leave_pressed
signal play_again_pressed

func _on_leave_game_pressed() -> void:
	get_tree().change_scene_to_file("res://HomeScreen.tscn")


func _on_play_again_pressed() -> void:
	get_tree().change_scene_to_file("res://LobbySelector.tscn")
