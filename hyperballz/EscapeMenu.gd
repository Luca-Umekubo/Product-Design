extends Control


func _on_resume_pressed() -> void:
	get_tree().change_scene_to_file("res://Game.tscn")


func _on_quit_pressed() -> void:
	get_tree().change_scene_to_file("res://HomeScreen.tscn") # Replace with function body.


func _on_keybinds_pressed() -> void:
	get_tree().change_scene_to_file("res://Keybinds.tscn") # Replace with function body.


func _on_game_settings_pressed() -> void:
	get_tree().change_scene_to_file("res://GameSettings.tscn") # Replace with function body.
