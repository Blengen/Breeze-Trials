extends Node

# COMPONENTS #
@onready var vars: Node = $"../shared_variables"
@onready var ability: Node = $"../ability"

# NODES #
@onready var player: CharacterBody3D = $"../../body"
@onready var fuel_label: Node = $"../fuel/label_fuel"

var map_settings: Node = null

var spawn: Node = null

var restart_juice: float = 0 # Timer for how long restart has been pressed. Resets to 0 if key released

func _ready() -> void:
	await get_tree().process_frame # Wait one frame to let the map load in
	
	# Define variables after the map loads
	spawn = $"../../../map/spawn"
	map_settings = $"../../../map/settings"
	
	await get_tree().process_frame
	await get_tree().process_frame # lol this is so stupid but it works
	
	restart()

func restart() -> void:
	vars.playing = false
	player.position = spawn.position
	$timer_respawn.start()
	$hihats.play("hihat_2")
	$hihats.speed_scale = global.reverse_time_scale
	$"../../body/visual/anim".play("RESET")
	$"../../cambase".rotation_degrees.y = spawn.rotation_degrees.y
	player.rotation_degrees.y = spawn.rotation_degrees.y
	$"../../body/visual/anim".speed_scale = 1
	player.velocity = Vector3.ZERO
	vars.speed = map_settings.starting_speed
	vars.jump = map_settings.starting_jump
	vars.grav = map_settings.starting_grav

	
	vars.fuel = map_settings.starting_fuel
	fuel_label.text = str(vars.fuel)
	$death_ui.hide()
	
		# Orb things
	await get_tree().process_frame
	for child in $"../../../map/orbs".get_children():
		child.show()
		child.collider.disabled = false
		
	for orb: Array in ability.ability_list:
		orb[2].timer.stop()
		orb[2]._timeout()
		ability.ability_list.pop_front()

func _on_timer_respawn_timeout() -> void:
	vars.playing = true
	player.move_and_slide()


func check_for_restart(delta: float) -> void:
	if Input.is_action_pressed("restart"): restart_juice += delta * global.reverse_time_scale
	else: restart_juice = 0

	if restart_juice > 0.5:
		restart()
		restart_juice = -9999999
		
func death(reason: String) -> void:
	vars.playing = false
	
	$"../gameloop/death_ui".show()
	$"../gameloop/death_ui/reason".text = reason
	$"../../body/visual/anim".speed_scale = 0
	$death.play()
	$death_ui/anim.play("RESET")
	$death_ui/anim.play("death")
	$"../../cambase/cam/shake".shake_node = true
