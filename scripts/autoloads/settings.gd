extends Node

var file_path: String = "res://settings.cfg"

# GAMEPLAY SETTINGS #
var sens: float = 0.1
var use_physics_process: bool = false

# VISUAL SETTINGS #
var fov: float = 90

const items: PackedStringArray = ["sens", "fps_cap", "game_speed", "w", "a", "s", "d", "jump", "quick_drop",
"ability", "camlock", "zoom_in", "zoom_out", "debug", "exit_settings", "upp", "fov"]

# AUDIO SETTINGS #
var music_volume: float = 1

func _ready() -> void:
	if not OS.has_feature("editor"): file_path = OS.get_executable_path().path_join("settings.cfg")
	save_settings()

func save_settings() -> void:
	var file: ConfigFile = ConfigFile.new()
	
	file.set_value("gameplay", "sens", settings.sens)
	file.set_value("gameplay", "game_speed", Engine.time_scale)
	file.set_value("gameplay", "upp", settings.use_physics_process)
	
	file.set_value("visual", "fov", settings.fov)
	
	file.set_value("audio", "music_volume", settings.music_volume)
	
	file.set_value("keybinds", "w", InputMap.action_get_events("front")[0])
	file.set_value("keybinds", "a", InputMap.action_get_events("left")[0])
	file.set_value("keybinds", "s", InputMap.action_get_events("back")[0])
	file.set_value("keybinds", "d", InputMap.action_get_events("right")[0])
	
	file.set_value("keybinds", "jump", InputMap.action_get_events("jump")[0])
	file.set_value("keybinds", "quick_drop", InputMap.action_get_events("quick_drop")[0])
	file.set_value("keybinds", "ability", InputMap.action_get_events("ability")[0])
	file.set_value("keybinds", "camlock", InputMap.action_get_events("camlock")[0])
	file.set_value("keybinds", "zoom_in", InputMap.action_get_events("zoom_in")[0])
	file.set_value("keybinds", "zoom_out", InputMap.action_get_events("zoom_out")[0])
	file.set_value("keybinds", "debug", InputMap.action_get_events("debug")[0])
	
	file.save(file_path)

func load_settings() -> void:
	if FileAccess.file_exists(file_path):
		
		var file: ConfigFile = ConfigFile.new()
		var load_error: Error = file.load(file_path)
		
		if not load_error == OK:
			print("Something went wrong loading settings: " + error_string(load_error))
			return
		
		settings.sens = file.get_value("gameplay", "sens", settings.sens)
		
		
		
		
	else: save_settings()
