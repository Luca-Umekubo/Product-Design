extends Node

var current_screen: Node = null

func _ready():
	print("ScreenManager ready")
	change_screen("res://scenes/Homescreen.tscn")

func change_screen(path: String):
	if current_screen:
		current_screen.queue_free()

	var scene = load(path).instantiate()
	current_screen = scene

	# ✅ Add to parent of ScreenManager (RootUI)
	get_parent().add_child(current_screen)

	print("Loading screen:", path)

	if path.ends_with("Homescreen.tscn"):
		scene.connect("host_pressed", Callable(self, "_on_Host_Pressed"))
		scene.connect("join_pressed", Callable(self, "_on_Join_Pressed"))
		scene.connect("test_pressed", Callable(self, "_on_Test_Pressed"))
		scene.connect("exit_pressed", Callable(self, "_on_Exit_Pressed"))
	elif path.ends_with("LobbyList.tscn"):
		scene.connect("return_pressed", Callable(self, "_on_Return_Pressed"))
	elif path.ends_with("EndScreen.tscn"):
		scene.connect("leave_pressed", Callable(self, "_on_Leave_Pressed"))
		scene.connect("play_again_pressed", Callable(self, "_on_Play_Again_Pressed"))

func _on_Host_Pressed():
	print("Host button pressed (implement later)")

func _on_Join_Pressed():
	print("Join signal received! Switching to LobbyList")
	change_screen("res://scenes/LobbyList.tscn")

func _on_Test_Pressed():
	print("Test button pressed (implement later)")

func _on_Exit_Pressed():
	print("Exit button pressed. Quitting.")
	get_tree().quit()

func _on_Return_Pressed():
	print("Returning to Homescreen")
	change_screen("res://scenes/Homescreen.tscn")

func _on_Leave_Pressed():
	print("Leaving game, going to Homescreen")
	change_screen("res://scenes/Homescreen.tscn")

func _on_Play_Again_Pressed():
	print("Play Again pressed, going to Homescreen (for now)")
	change_screen("res://scenes/Homescreen.tscn")
