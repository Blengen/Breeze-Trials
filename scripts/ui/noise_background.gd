extends TextureRect

func _process(delta: float) -> void:
	texture.noise.offset.y += delta * 7 * global.reverse_time_scale
