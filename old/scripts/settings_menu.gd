extends TextureRect

var from: String = global.from

func _ready() -> void: load_settings_in_boxes()

func load_settings_in_boxes() -> void:
	$scroll_box/vbox/sens/sens_box.text = str(global.sens)
	$scroll_box/vbox/game_speed/game_speed_box.text = str(global.game_speed)
	$scroll_box/vbox/music_volume_slider.value = global.music_volume
	$scroll_box/vbox/fps_cap/fps_cap_box.text = str(global.fps_cap)
	$scroll_box/vbox/fov/fov_box.text = str(global.fov)

func _on_sens_box_text_changed(new_text: String) -> void: if new_text.is_valid_float(): global.change_setting("controls", "sensitivity", abs(new_text.to_float()))
func _on_game_speed_box_text_changed(new_text: String) -> void: if new_text.is_valid_float(): global.change_setting("controls", "game_speed", abs(new_text.to_float()))
func _on_music_volume_slider_value_changed(value: float) -> void: global.change_setting("audio", "music_volume", value)
func _on_fps_cap_box_text_changed(new_text: String) -> void: if new_text.is_valid_int(): global.change_setting("visuals", "fps_cap", abs(new_text.to_int()))
func _on_fov_box_text_changed(new_text: String) -> void: if new_text.is_valid_float(): global.change_setting("visuals", "fov", clamp(new_text.to_float(), 5, 175))


func _on_back_pressed() -> void:
	global.from = "settings"
	match from:
		"menu": get_tree().change_scene_to_file("res://scenes/menu/main_menu.tscn")
		"ingame": get_tree().change_scene_to_file("res://scenes/ingame/ingame.tscn")
		"editor": get_tree().change_scene_to_file("res://scenes/ingame/editor.tscn")
		_: get_tree().change_scene_to_file("res://scenes/menu/main_menu.tscn")
