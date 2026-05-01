extends AnimationPlayer

var timescale: float = randf_range(0.85, 1.15)

func _ready() -> void:
	play("pulse")
	fix_timescale()
	settings.settings_changed.connect(fix_timescale)

func fix_timescale() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	speed_scale = timescale * global.reverse_time_scale
	
