extends Area3D

@onready var collider = $collider
@onready var timer = $timer

var type
var value

func _ready() -> void:
	type = $type.editor_description
	value = $value.editor_description
	match type:
		"dash": $icon.texture = load("res://images/orb_icons/dash.png")
		"jump": $icon.texture = load("res://images/orb_icons/jump.png")
		"stat_speed": $icon.texture = load("res://images/orb_icons/stat_speed.png")
		"stat_jump": $icon.texture = load("res://images/orb_icons/stat_jump.png")
		"fuel": $icon.texture = load("res://images/orb_icons/fuel.png")
		"end": $icon.texture = load("res://images/orb_icons/end.png")


func _on_timer_timeout() -> void:
	visible = true
	collider.disabled = false
