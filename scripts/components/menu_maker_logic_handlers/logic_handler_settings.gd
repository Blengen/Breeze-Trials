extends Node

const is_input_list: PackedStringArray = ["sens", "game_speed", "fps_cap", "music_volume", "fov"]
const is_bool_list: PackedStringArray = ["upp"]
const is_key_list: PackedStringArray = ["w", "a", "s", "d", "jump", "quick_drop", "ability", "camlock", "zoom_in", "zoom_out", "debug"]

const button_ids: PackedStringArray = ["sens", "fps_cap", "game_speed", "w", "a", "s", "d", "jump", "quick_drop", "ability", "camlock", "zoom_in", "zoom_out", "debug", "exit_settings", "upp", "fov", "music_volume"]

var id: String = ""

signal settings_changed

@onready var key_input: Control = $"../../key_input" 

func _input(event: InputEvent) -> void: # Input collection for custom keybinds
	if !key_input.visible: return # Only run if seeking keybind
	if not (event is InputEventMouseButton or event is InputEventKey): return # Only run on keybind
	if event.is_action_pressed("esc"): # Cancel operation
		key_input.hide()
		emit_signal("settings_changed")
		return
	
# THUKUNA :DDD
	
	else:
		get_viewport().set_input_as_handled()
		rebind(event)

func rebind(key: InputEvent) -> void:
	match id:
		"w":
			print(key)
			InputMap.action_erase_events("front")
			InputMap.action_add_event("front", key)
		"a":
			InputMap.action_erase_events("left")
			InputMap.action_add_event("left", key)
		"s":
			InputMap.action_erase_events("back")
			InputMap.action_add_event("back", key)
		"d":
			InputMap.action_erase_events("right")
			InputMap.action_add_event("right", key)
		"jump":
			InputMap.action_erase_events("jump")
			InputMap.action_add_event("jump", key)
		"quick_drop":
			InputMap.action_erase_events("quick_drop")
			InputMap.action_add_event("quick_drop", key)
		"ability":
			InputMap.action_erase_events("ability")
			InputMap.action_add_event("ability", key)
		"camlock":
			InputMap.action_erase_events("camlock")
			InputMap.action_add_event("camlock", key)
		"zoom_in":
			InputMap.action_erase_events("zoom_in")
			InputMap.action_add_event("zoom_in", key)
		"zoom_out":
			InputMap.action_erase_events("zoom_out")
			InputMap.action_add_event("zoom_out", key)
		"debug":
			InputMap.action_erase_events("debug")
			InputMap.action_add_event("debug", key)
	

	key_input.hide()
	update_button_values()
	
	
func button_press(new_id: String) -> void:
	id = new_id
	
	var type: String = ""
	if is_input_list.has(id): type = "input"
	if is_bool_list.has(id): type = "bool"
	elif is_key_list.has(id): type = "key"
	
	if type == "input": $"../../text_input".show()
	elif type == "key": key_input.show()
	elif type == "bool":
		match id:
			"upp": settings.use_physics_process = !settings.use_physics_process
	
	if id == "exit_settings": $"../..".hide()
	
	update_button_values()


func _on_lineedit_text_submitted(val: String) -> void:
	
	$"../../text_input/lineedit".text = ""
	
	$"../../text_input".hide()
	match id:
		"sens": if val.is_valid_float(): settings.sens =  float(val)
		"fps_cap": if val.is_valid_int():
			Engine.max_fps = abs(int(val))
			if Engine.max_fps != 0 and Engine.max_fps < 5: Engine.max_fps = 5
			Engine.get_version_info()
		"game_speed": if val.is_valid_float():
			Engine.time_scale = float(val)
			global.reverse_time_scale = 1 / Engine.time_scale
			
		"music_volume": if val.is_valid_float(): settings.music_volume = float(val)
		"fov":
			if val.is_valid_float(): settings.fov = float(val)
			settings.fov = clamp(settings.fov, 1, 175)
	
	update_button_values()
	emit_signal("settings_changed")

func update_button_values() -> void:
	
	await get_tree().process_frame
	var button_node: Button = null
	
	for item in button_ids:
		for node in $"../scroll/vbox".get_children():
			if node is Button and node.id == item:
				button_node = node
				break
				
		match item:
			"sens": button_node.text = "Sensitivity: " + str(settings.sens)
			"fps_cap": button_node.text = "FPS Cap: " + str(Engine.max_fps)
			"game_speed": button_node.text = "Game Speed: " + str(Engine.time_scale)
			"music_volume": button_node.text = "Music Volume: " + str(settings.music_volume)
			"upp": button_node.text = "Use Physics Process: " + str(settings.use_physics_process)
			"fov": button_node.text = "FOV: " + str(settings.fov)
			
			"w": button_node.text = "Move Forward: " + get_key_string("front")
			"a": button_node.text = "Move Left: " + get_key_string("left")
			"s": button_node.text = "Move Back: " + get_key_string("back")
			"d": button_node.text = "Move Right: " + get_key_string("right")
			"jump": button_node.text = "Jump: " + get_key_string("jump")
			"quick_drop": button_node.text = "Quick Drop: " + get_key_string("quick_drop")
			"ability": button_node.text = "Use Ability: " + get_key_string("ability")
			"camlock": button_node.text = "Camlock: " + get_key_string("camlock")
			"zoom_in": button_node.text = "Zoom In: " + get_key_string("zoom_in")
			"zoom_out": button_node.text = "Zoom Out: " + get_key_string("zoom_out")
			"debug": button_node.text = "Debug: " + get_key_string("debug")

func get_key_string(action: StringName) -> String:
	var key: InputEvent = InputMap.action_get_events(action)[0]
	
	if key is InputEventKey: return str(OS.get_keycode_string(key.keycode))
	elif key is InputEventMouseButton: match key.button_index:
		1: return "LMB"
		2: return "RMB"
		3: return "MMB"
		4: return "Wheel Up"
		5: return "Wheel Down"
		8: return "Back Side Button"
		9: return "Front Side button"
	
	return "Unknown Button"
