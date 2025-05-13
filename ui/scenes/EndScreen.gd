extends Control

signal leave_pressed
signal play_again_pressed

func _on_Leave_Game_pressed():
	emit_signal("leave_pressed")

func _on_Play_Again_pressed():
	emit_signal("play_again_pressed")
