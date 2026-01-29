extends Node

var selected_map: String = "res://scenes/test_map.tscn"
var entered_from_editor: bool = false

# SETTINGS VARIABLES
var sens: float = 0.1

var exit_juice: float = 0 # Time counter for exiting

func _process(delta: float) -> void:
	check_exit(delta)

func check_exit(delta: float) -> void:
	if not Input.is_action_pressed("esc"): exit_juice = 0
	else: 
		exit_juice += delta
		if exit_juice > 0.5:
			get_tree().change_scene_to_file("res://scenes/menu/main_menu.tscn")
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
