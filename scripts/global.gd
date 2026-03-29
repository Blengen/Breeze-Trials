extends Node

var settings_file: String = "res://settings.cfg"

var selected_map: String = "res://scenes/maps/test_map.btmap.tscn"
var from: String = "menu"

# SETTINGS VARIABLES

# CONTROLS
var sens: float = 0.1
var game_speed: float = 1

# AUDIO
var music_volume: int = 100

# GRAPHICS
var fps_cap: int = 0
var fov: float = 0

# EDITOR
var cam_pos: Vector3 = Vector3.ZERO



func _ready() -> void:
	if not OS.has_feature("editor"): settings_file = OS.get_executable_path().get_base_dir().path_join("settings.cfg")
	var config: ConfigFile = ConfigFile.new()
	if config.load(settings_file) != OK: make_new_settings_file() # Loads settings, but also returns an error if there is none, and makes a new one.
	load_settings()
		
	
func make_new_settings_file() -> void:
	var config: ConfigFile = ConfigFile.new()
	
	# CONTROLS
	config.set_value("controls", "sensitivity", 0.1)
	config.set_value("controls", "game_speed", 1)
	
	# AUDIO
	config.set_value("audio", "music_volume", 100)
	
	# GRAPHICS
	config.set_value("visuals", "fps_cap", 0)
	config.set_value("visuals", "fov", 90)
	
	config.save(settings_file)
	


func change_setting(category: String, setting: String, value: Variant) -> void:
	var config: ConfigFile = ConfigFile.new()
	if config.load(settings_file) != OK: make_new_settings_file() # Loads settings, but also returns an error if there is none, and makes a new one.
	
	config.set_value(category, setting, value)
	config.save(settings_file)
	load_settings()
	
func load_settings() -> void:
	var config: ConfigFile = ConfigFile.new()
	if config.load(settings_file) != OK: make_new_settings_file() # Loads settings, but also returns an error if there is none, and makes a new one.
	
	# lol this is gonna get long
	
	sens = config.get_value("controls", "sensitivity")
	game_speed = config.get_value("controls", "game_speed")
	music_volume = config.get_value("audio", "music_volume")
	fps_cap = config.get_value("visuals", "fps_cap")
	fov = config.get_value("visuals", "fov")

	Engine.max_fps = fps_cap
	Engine.time_scale = game_speed
