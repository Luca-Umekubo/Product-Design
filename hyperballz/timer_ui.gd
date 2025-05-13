extends Control

@onready var timer_label = $TimerLabel

func _ready():
	# Ensure the UI is visible
	visible = true

# Called via RPC from game.gd to update the timer display
func update_timer_display(time_left: float):
	var minutes = int(time_left / 60)
	var seconds = int(time_left) % 60
	timer_label.text = "%d:%02d" % [minutes, seconds]

func _process(_delta):
	var timer_sync = get_node("../../TimerSync")
	if timer_sync:
		var time_left = timer_sync.time_left
		var minutes = int(time_left / 60)
		var seconds = int(time_left) % 60
		timer_label.text = "%d:%02d" % [minutes, seconds]
