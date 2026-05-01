extends Node

var file_path: String = "res://settings.cfg"

# GAMEPLAY SETTINGS #
var sens: float = 0.1
var use_physics_process: bool = false

# VISUAL SETTINGS #
var fov: float = 90
var show_fps: bool = true

const items: PackedStringArray = ["sens", "fps_cap", "game_speed", "w", "a", "s", "d", "jump", "quick_drop",
"ability", "camlock", "zoom_in", "zoom_out", "debug", "exit_settings", "upp", "fov", "show_fps", "physics_fps"]

# AUDIO SETTINGS #
var music_volume: float = 1

# SIGNALS
@warning_ignore("unused_signal")
signal settings_changed

func _ready() -> void:
	if not OS.has_feature("editor"): file_path = OS.get_executable_path().path_join("settings.cfg")
	load_settings()
	save_settings()

func save_settings() -> void:
	var file: ConfigFile = ConfigFile.new()
	
	file.set_value("gameplay", "sens", settings.sens)
	file.set_value("gameplay", "game_speed", Engine.time_scale)
	file.set_value("gameplay", "upp", settings.use_physics_process)
	file.set_value("gameplay", "physics_fps", Engine.physics_ticks_per_second)
	
	file.set_value("visual", "fov", settings.fov)
	file.set_value("visual", "show_fps", settings.show_fps)
	
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
	
""" Old human-written code (got DeepSeek to do this since it's a repetetive task)
func load_settings() -> void:
	if FileAccess.file_exists(file_path):
		
		var file: ConfigFile = ConfigFile.new()
		var load_error: Error = file.load(file_path)
		
		if not load_error == OK:
			print("Something went wrong loading settings: " + error_string(load_error))
			return
		
		if file.has_section_key("gameplay", "sens"): settings.sens = file.get_value("gameplay", "sens", settings.sens)
		if file.has_section_key("gameplay", "game_speed"): Engine.time_scale = file.get_value("gameplay", "game_speed", Engine.time_scale)
		# ETCETERA
	
	save_settings()
"""	

func load_settings() -> void:
	if FileAccess.file_exists(file_path):
		var file: ConfigFile = ConfigFile.new()
		var load_error: Error = file.load(file_path)
		
		if not load_error == OK:
			print("Something went wrong loading settings: " + error_string(load_error))
			return
		
		# Gameplay
		if file.has_section_key("gameplay", "sens"): settings.sens = file.get_value("gameplay", "sens", settings.sens)
		if file.has_section_key("gameplay", "game_speed"): Engine.time_scale = file.get_value("gameplay", "game_speed", Engine.time_scale)
		if file.has_section_key("gameplay", "upp"): settings.use_physics_process = file.get_value("gameplay", "upp", settings.use_physics_process)
		if file.has_section_key("gameplay", "physics_fps"): Engine.physics_ticks_per_second = file.get_value("gameplay", "physics_fps", Engine.physics_ticks_per_second)
		
		# Visual
		if file.has_section_key("visual", "fov"): settings.fov = file.get_value("visual", "fov", settings.fov)
		if file.has_section_key("visual", "show_fps"): settings.show_fps = file.get_value("visual", "show_fps", settings.show_fps)
		
		# Audio
		if file.has_section_key("audio", "music_volume"): settings.music_volume = file.get_value("audio", "music_volume", settings.music_volume)
		
		# Keybinds
		_apply_keybind_from_file(file, "keybinds", "w", "front")
		_apply_keybind_from_file(file, "keybinds", "a", "left")
		_apply_keybind_from_file(file, "keybinds", "s", "back")
		_apply_keybind_from_file(file, "keybinds", "d", "right")
		_apply_keybind_from_file(file, "keybinds", "jump", "jump")
		_apply_keybind_from_file(file, "keybinds", "quick_drop", "quick_drop")
		_apply_keybind_from_file(file, "keybinds", "ability", "ability")
		_apply_keybind_from_file(file, "keybinds", "camlock", "camlock")
		_apply_keybind_from_file(file, "keybinds", "zoom_in", "zoom_in")
		_apply_keybind_from_file(file, "keybinds", "zoom_out", "zoom_out")
		_apply_keybind_from_file(file, "keybinds", "debug", "debug")

func _apply_keybind_from_file(file: ConfigFile, section: String, key: String, action: String) -> void:
	if file.has_section_key(section, key):
		var event: InputEvent = file.get_value(section, key)
		if event is InputEvent:
			# Remove existing events for this action
			for old in InputMap.action_get_events(action):
				InputMap.action_erase_event(action, old)
			# Add the loaded event
			InputMap.action_add_event(action, event)
