extends Area3D

@onready var collider = $collider
@onready var timer = $timer

var type
var value

func _ready() -> void:
	type = $type.editor_description
	value = float($value.editor_description)
	match type:
		"dash": $icon.texture = load("res://images/orb_icons/dash.png")
		"jump": $icon.texture = load("res://images/orb_icons/jump.png")
		"stat_speed": $icon.texture = load("res://images/orb_icons/stat_speed.png")
		"stat_jump": $icon.texture = load("res://images/orb_icons/stat_jump.png")
		"fuel": $icon.texture = load("res://images/orb_icons/fuel.png")
		"end": $icon.texture = load("res://images/orb_icons/end.png")

	if type == "dash" or type == "jump": $mesh.material_overlay = load("res://materials/orb/white_outline.tres")
	elif type == "stat_speed" or type == "stat_jump": $mesh.material_overlay = load("res://materials/orb/blue_outline.tres")
	elif type == "fuel" or type == "end": $mesh.material_overlay = load("res://materials/orb/green_outline.tres")

	
	#else:
		#$mesh.material_overlay = load("res://materials/orb/white_outline.tres")
		#print("failsafe triggered")




func _on_timer_timeout() -> void:
	visible = true
	collider.disabled = false
