extends Node

# Nodes (because logic in loops, yes)
@onready var player: CharacterBody3D = $"../../body"
@onready var cambase: Node3D = $"../../cambase"

# Components
@onready var move_xz: Node = $"../move_xz"
@onready var move_y: Node = $"../move_y"
@onready var animation: Node = $"../animation"
@onready var fuel: Node = $"../fuel"
@onready var gameloop: Node = $"../gameloop"
@onready var camera: Node = $"../camera"
@onready var ability: Node = $"../ability"

@onready var vars: Node = $"../shared_variables"

func _process(delta: float) -> void: if !settings.use_physics_process: loops(delta)
func _physics_process(delta: float) -> void: if settings.use_physics_process: loops(delta)
	
func loops(delta: float) -> void:
	
	if vars.playing:
		move_xz.input_movement(delta)
		
		move_y.air(delta)
		move_y.jump()
		move_y.ledge()
		
		ability.input()
		
		fuel.fuel_tick(delta)
		
		animation.animate(delta)
		
		
		if vars.playing and player.velocity: player.move_and_slide()
	
	gameloop.check_for_restart(delta)	
	camera.align()
