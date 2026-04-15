extends Node

# Nodes (because logic in loops, yes)
@onready var player: CharacterBody3D = $"../../body"
@onready var cambase: Node3D = $"../../cambase"

# Components
@onready var move_xz: Node = $"../move_xz"
@onready var move_y: Node = $"../move_y"
@onready var animation: Node = $"../animation"

var upp: bool = global.use_physics_process # UPP = "Use Physics Process"

func _process(delta: float) -> void: if !upp: loops(delta)
func _physics_process(delta: float) -> void: if upp: loops(delta)
	
func loops(delta: float) -> void:
	
	move_xz.input_movement()
	
	move_y.jump()
	move_y.air(delta)
	move_y.ledge()
	
	animation.animate()
	
	if player.velocity: player.move_and_slide()
	cambase.position = player.position + Vector3(0, 1.5, 0)
