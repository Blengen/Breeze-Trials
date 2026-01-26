extends Area3D

const group: String = "orb"

@onready var collider = $collider
@onready var timer = $timer

@export var type: String = "none"
@export var value: float = 0

const type_orb: bool = true

func _ready() -> void:
	match type:
		"dash": $icon.texture = load("res://images/orb_icons/dash.png")
		"jump": $icon.texture = load("res://images/orb_icons/jump.png")
		"stat_speed": $icon.texture = load("res://images/orb_icons/stat_speed.png")
		"stat_jump": $icon.texture = load("res://images/orb_icons/stat_jump.png")
		"fuel": $icon.texture = load("res://images/orb_icons/fuel.png")
		"end": $icon.texture = load("res://images/orb_icons/end.png")

	
	#else:
		#$mesh.material_overlay = load("res://materials/orb/white_outline.tres")
		#print("failsafe triggered")




func _on_timer_timeout() -> void:
	visible = true
	collider.disabled = false
