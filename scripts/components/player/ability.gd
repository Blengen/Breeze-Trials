extends Node

#@onready var player: CharacterBody3D = $"../../body"

# COMPONENTS #
@onready var vars: Node = $"../shared_variables"

var type: String = ""
var value: float = 0

func orb_hit(orb: Area3D) -> void:
	
	type = orb.type
	value = orb.value
	
	match type:
		"dash": dash()
		"jump": jump()
		"stat_speed":
			vars.speed = value
			global.stat_speed = value
			for child in orb.get_parent().get_children(): child.load_texture()
		"stat_jump":
			vars.jump = value
			global.stat_jump = value
			for child in orb.get_parent().get_children(): child.load_texture()
		"fuel": fuel()
		"end": end()
		

func dash() -> void:
	pass

func jump() -> void:
	pass
	
func fuel() -> void:
	pass
	
func end() -> void:
	pass
