extends Node

# NODES #
@onready var player: CharacterBody3D = $"../../body"
@onready var cambase: Node = $"../../cambase"

# COMPONENTS #
@onready var vars: Node = $"../shared_variables"
@onready var gameloop: Node = $"../gameloop"


var type: String = ""
var value: float = 0
var buffering: bool = false

var ability_list: Array[Array] = []

func orb_hit(orb: Area3D) -> void:
	
	type = orb.type
	value = orb.value
	
	match type:
		
		"dash", "jump":
			ability_list.append([type, value, orb])
			orb.hide()
			orb.collider.set_deferred("disabled", true)


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
			
		"fuel":
			if vars.fuel >= 0:
				vars.fuel += value
				orb.hide()
				orb.collider.set_deferred("disabled", true)
			else:
				gameloop.death("Off by " + str(abs(snapped(vars.fuel, 0.001))) + "s")
			
		"end":
			if vars.fuel >= 0: gameloop.death("Won by " + str(abs(snapped(vars.fuel, 0.001))) + "s")
			else: gameloop.death("Off by " + str(abs(snapped(vars.fuel, 0.001))) + "s")
				
		
func put_orb_on_cooldown(orb: Area3D) -> void:
	orb.hide()
	orb.collider.set_deferred("disabled", true)
	orb.timer.start()

func update_orbs(orb: Area3D) -> void:
	if orb: for child in orb.get_parent().get_children(): child.load_texture()

func do_ability() -> void:
	var ability: Array = ability_list[0]
	ability_list.pop_front()
	
	if ability[0] == "dash":
		var offset: float = vars.vec2_to_deg(Input.get_vector("left", "right", "front", "back"))
		var old_cambase_rotation: Vector3 = cambase.rotation_degrees
		cambase.rotation_degrees.x = 0
		cambase.rotation_degrees.y += offset

		
		player.velocity = cambase.transform.basis * Vector3(0, player.velocity.y, -ability[1])
		if player.velocity.y < 1: player.velocity.y = 1
		cambase.rotation_degrees = old_cambase_rotation
		ability[2].timer.start()
		

	elif ability[0] == "jump":
		player.velocity.y = ability[1]
		ability[2].timer.start()
		
func input() -> void:
	if Input.is_action_pressed("ability"):
		if Input.is_action_just_pressed("ability"): buffering = true
		
		if buffering and ability_list:
			do_ability()
			buffering = false
		
