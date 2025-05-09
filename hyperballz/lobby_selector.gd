extends Control

func _on_join_button_pressed():
	var ip = $VBoxContainer/IPLineEdit.text
	var port = int($VBoxContainer/PortLineEdit.text)
	print("join")
	Network.join_server(ip, port)
	get_tree().change_scene_to_file("res://Game.tscn")
