extends Control

var exitjuice: float = 0

@onready var scene: Control = $"main_menu"

@onready var main: Control = $"main_menu"
@onready var maps: Control = $"maps"
@onready var credits: Control = $"credits"

@onready var custom: Control = $"custom"
@onready var files: FileDialog = $custom/files

var load_mode: String = "play"

func _ready() -> void:
	global.from = "menu"
	$main_menu/title/ani.play("pulse")
	$main_menu/title/ani.speed_scale = 1 / global.game_speed

func _process(delta: float) -> void:
	# Exit
	
	if Input.is_action_pressed("esc"): exitjuice += delta
	else: exitjuice = 0
	
	if exitjuice > 0.5:
		exitjuice = -9999
		
		if scene == main: pass # get_tree().quit()
		else: menu(main)

# MENU BUTTONS
# Syntax: _oldmenu_newmenu():
# menu() argument is the node of the new menu.

func menu(new: Node) -> void:
	scene.hide()
	new.show()
	scene = new
	
# From Main Menu
func _main_maps() -> void: menu(maps)
func _main_custom() -> void: menu(custom)
func _main_settings() -> void:
	global.from = "menu"
	get_tree().change_scene_to_file("res://scenes/menu/settings.tscn")
func _main_credits() -> void: menu(credits)
func _main_quit() -> void: get_tree().quit()

# Returns
func _maps_main() -> void: menu(main)
func _cm_main() -> void: menu(main)
func _credits_exit() -> void: menu(main)

# --- # --- # --- # --- # --- # --- # --- #

func _main_maps_list_click(index: int, _at_position: Vector2, _mouse_button_index: int) -> void:
	if index == 3: get_tree().change_scene_to_file("res://scenes/ingame/ingame.tscn")

func _on_custom_maps_list_item_clicked(index: int, _at_position: Vector2, _mouse_button_index: int) -> void:
	if index == 0: load_mode = "play"
	if index == 1: load_mode = "edit"
	if index == 2:
		global.selected_map = "res://scenes/map_template.btmap.tscn"
		get_tree().change_scene_to_file("res://scenes/ingame/editor.tscn")
		return
		
	files.show()


func _on_files_file_selected(path: String) -> void:
	if not path.ends_with(".btmap.tscn"): return
	global.selected_map = path
	if load_mode == "play": get_tree().change_scene_to_file("res://scenes/ingame/ingame.tscn")
	else: get_tree().change_scene_to_file("res://scenes/ingame/editor.tscn")


	
