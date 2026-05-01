extends Node

@onready var label: Label = $debug_label

func _on_timer_timeout() -> void:
	label.text = ""
	
	if settings.show_fps:
		label.text += "FPS: " + str(Engine.get_frames_per_second()) + "
"
	if Engine.time_scale != 1:
		label.text += "Game Speed: " + str(Engine.time_scale) + "
"
