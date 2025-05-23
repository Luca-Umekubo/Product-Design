extends Node

var gravity_multiplier: float = 1.0:
	set(value):
		gravity_multiplier = value
		gravity_multiplier_changed.emit(value)

signal gravity_multiplier_changed(new_value: float)
