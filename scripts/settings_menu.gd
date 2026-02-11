extends TextureRect

func load_settings_in_boxes() -> void:
	$scroll_box/vbox/sens_box.text = str(global.sens)
	$scroll_box/vbox/music_volume_slider.value = global.music_volume
	$scroll_box/vbox/fps_cap_box.text = str(global.fps_cap)

func _on_sens_box_text_changed(new_text: String) -> void: if new_text.is_valid_float(): global.change_setting("controls", "sensitivity", new_text.to_float())
func _on_music_volume_slider_value_changed(value: float) -> void: global.change_setting("audio", "music_volume", value)
func _on_fps_cap_box_text_changed(new_text: String) -> void: if new_text.is_valid_int(): global.change_setting("visuals", "fps_cap", new_text.to_int())


func _on_fov_box_text_changed(new_text: String) -> void:
	if new_text.is_valid_float():
		var new_fov = clamp(new_text.to_float(), 5, 175)
		global.change_setting("visuals", "fov", new_fov)
