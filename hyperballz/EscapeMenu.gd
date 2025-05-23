extends Control

# Reference the UI nodes
@onready var keybinds = $Keybinds
@onready var game_settings = $GameSettings

func _ready():
	# Check if nodes are properly referenced
	if not keybinds or not game_settings:
		push_error("Keybinds or GameSettings node not found! Make sure they are children of EscapeMenu.")
		return
	
	# Ensure initial visibility: show this node (EscapeMenu), hide others
	visible = true
	keybinds.hide()
	game_settings.hide()
	
	# Connect signals for buttons in EscapeMenu
	# Adjust the paths based on your button names in the GridContainer
	get_node("GridContainer/GameSettingsButton").pressed.connect(_on_game_settings_pressed)
	get_node("GridContainer/KeybindsButton").pressed.connect(_on_keybinds_pressed)
	get_node("GridContainer/Quit").pressed.connect(_on_quit_pressed)
	get_node("GridContainer/Resume").pressed.connect(_on_resume_pressed)

func _on_resume_pressed():
	# Hide all UI and unpause
	hide()
	if keybinds:
		keybinds.hide()
	if game_settings:
		game_settings.hide()
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _on_quit_pressed():
	# Disconnect from multiplayer and return to main menu
	get_tree().get_multiplayer().multiplayer_peer.close()
	get_tree().change_scene_to_file("res://EndScreen.tscn")

func _on_keybinds_pressed():
	# Load and switch to the Keybinds scene
	var keybinds_scene = load("res://Keybinds.tscn").instantiate()
	get_tree().root.add_child(keybinds_scene)
	hide()
	queue_free()  # Remove the current escape menu

func _on_game_settings_pressed():
	# Load and switch to the GameSettings scene
	var game_settings_scene = load("res://GameSettings.tscn").instantiate()
	get_tree().root.add_child(game_settings_scene)
	hide()
	queue_free()  # Remove the current escape menu
