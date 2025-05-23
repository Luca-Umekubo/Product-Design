extends Node

# Team colors
const TEAM_A_COLOR = Color(0.752941, 0.223529, 0.168627, 1)  # Red
const TEAM_B_COLOR = Color(0.160784, 0.501961, 0.72549, 1)   # Blue
const NEUTRAL_COLOR = Color(0.8, 0.8, 0.8, 1)                # Light gray

# Get team color based on team index
static func get_color_for_team(team_index: int) -> Color:
	if team_index == 0:
		return TEAM_A_COLOR
	elif team_index == 1:
		return TEAM_B_COLOR
	else:
		return NEUTRAL_COLOR

# Create a StandardMaterial3D with the team color
static func create_team_material(team_index: int) -> StandardMaterial3D:
	var material = StandardMaterial3D.new()
	material.albedo_color = get_color_for_team(team_index)
	return material
