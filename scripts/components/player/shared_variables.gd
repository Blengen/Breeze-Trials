extends Node

var components: Array[Node] = []

var speed: float = 20
var jump: float = 60
var grav: float = 250

var coyote: float = 0

var camlock: bool = false

var playing: bool = false
var fuel: float = 0

func vec2_to_deg(value: Vector2) -> int:
	match value:
		Vector2(0, -1): return 0
		Vector2(-1, 0): return 90
		Vector2(0, 1): return 180
		Vector2(1, 0): return 270
		
	if value.x < -0.5 and value.y < -0.5: return 45
	elif value.x < -0.5 and value.y > 0.5: return 135
	elif value.x > 0.5 and value.y > 0.5: return 235
	elif value.x > 0.5 and value.y < -0.5: return 315
	
	return 0
