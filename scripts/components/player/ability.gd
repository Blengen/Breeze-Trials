extends Node

# NODES #
@onready var player: CharacterBody3D = $"../../body"
@onready var cambase: Node = $"../../cambase"

# COMPONENTS #
@onready var vars: Node = $"../shared_variables"


var type: String = ""
var value: float = 0

var ability_list: Array[Array] = []

func orb_hit(orb: Area3D) -> void:
	
	type = orb.type
	value = orb.value
	
	match type:
		
		"dash", "jump":
			ability_list.append([type, value, orb])
			orb.hide()
			orb.collider.set_deferred("disabled", true)
			print(ability_list)

		"stat_speed":
			vars.speed = value
			global.stat_speed = value
			update_orbs(orb)
			put_orb_on_cooldown(orb)

		"stat_jump":
			vars.jump = value
			global.stat_jump = value
			for child in orb.get_parent().get_children(): child.load_texture()
			
			update_orbs(orb)
			put_orb_on_cooldown(orb)
			
		"fuel": pass # TODO
		"end": pass # TODO
		
func put_orb_on_cooldown(orb: Area3D) -> void:
	orb.hide()
	orb.collider.set_deferred("disabled", true)
	orb.timer.start()

func update_orbs(orb: Area3D) -> void:
	if orb: for child in orb.get_parent().get_children(): child.load_texture()

func ability_key_pressed() -> void:
	if !ability_list: return
	var ability: Array = ability_list[0]
	ability_list.pop_front()
	
	if ability[0] == "dash":
		var offset: float = vars.vec2_to_deg(Input.get_vector("left", "right", "front", "back"))
		var old_cambase_rotation: Vector3 = cambase.rotation_degrees
		cambase.rotation.x = 0
		cambase.rotation.y -= offset
		
		print(cambase.transform.basis * Vector3(0, 0, -ability[1]))
		player.velocity += cambase.transform.basis * Vector3(0, 0, -ability[1])
		cambase.rotation_degrees = old_cambase_rotation
		ability[2].timer.start()


		
