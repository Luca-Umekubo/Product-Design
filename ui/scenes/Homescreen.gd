extends Control

signal host_pressed
signal join_pressed
signal test_pressed
signal exit_pressed

func _on_Host_pressed():
	emit_signal("host_pressed")

func _on_Join_pressed():
	emit_signal("join_pressed")

func _on_Test_pressed():
	emit_signal("test_pressed")

func _on_Exit_Program_pressed():
	emit_signal("exit_pressed")
