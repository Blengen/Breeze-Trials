extends AnimationPlayer

func _ready() -> void:
	play("pulse")
	speed_scale = randf_range(0.85, 1.15)
