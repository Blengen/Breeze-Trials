extends Node

@onready var vars: Node = $"../shared_variables"
@onready var player: CharacterBody3D = $"../../body"
@onready var cambase: Node3D = $"../../cambase"

func input_movement() -> void:
	var vec: Vector2 = Input.get_vector("left", "right", "front", "back", )
	var vec_normalized: Vector2 = vec.normalized()
	
	# SET VELOCITY #
	
	# Get basis by reseting cambase x rotation to 0
	var cambase_rot_x: float = cambase.rotation_degrees.x
	cambase.rotation_degrees.x = 0
	var cambasis: Basis = cambase.basis
	cambase.rotation_degrees.x = cambase_rot_x
	
	player.velocity = cambasis * Vector3(vec_normalized.x * vars.speed, player.velocity.y, vec_normalized.y * vars.speed)
