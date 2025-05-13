#lobby_selector.gd

extends Control

func _on_join_button_pressed():
	var ip = $VBoxContainer/IPLineEdit.text
	var port = int($VBoxContainer/PortLineEdit.text)
	Network.join_server(ip, port)
	get_tree().change_scene_to_file("res://Pregame.tscn")
