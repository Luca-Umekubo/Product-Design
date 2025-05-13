extends Control

signal return_pressed

func _on_Return_pressed():
	emit_signal("return_pressed")
