extends Label

func _on_update_timer_timeout() -> void:
	text = "FPS: " + str(Engine.get_frames_per_second())
