extends Node

# FOLDERS
var save_dir: String
var map_dir: String
var music_dir: String

# SETTINGS VARIABLES
var sens: float = 0.1

var exit_juice: float = 0 # Time counter for exiting

func _ready() -> void:
	paths()
	fix_paths()
	
func paths() -> void:
	if OS.has_feature("editor"): save_dir = "res://save_data"
	else: save_dir = OS.get_executable_path().get_base_dir().path_join("save_data")
	
	map_dir = save_dir.path_join("maps")
	music_dir = save_dir.path_join("music")

func fix_paths() -> void: # Deepseek Code
	# Create directories if they don't exist
	var dir: DirAccess = DirAccess.open(save_dir)
	if not dir.dir_exists(map_dir):
		dir.make_dir_recursive(map_dir)
	if not dir.dir_exists(music_dir):
		dir.make_dir_recursive(music_dir)

func _process(delta: float) -> void:
	check_exit(delta)

func check_exit(delta: float) -> void:
	if not Input.is_action_pressed("esc"): exit_juice = 0
	else: 
		exit_juice += delta
		if exit_juice > 0.5:
			get_tree().change_scene_to_file("res://scenes/menu/main_menu.tscn")
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
