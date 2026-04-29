extends Node

@onready var vars: Node = $"../shared_variables"
@onready var player: CharacterBody3D = $"../../body"
@onready var cambase: Node3D = $"../../cambase"

func input_movement(delta: float) -> void:
	var vec: Vector2 = Input.get_vector("left", "right", "front", "back", )
	var vec_normalized: Vector2 = vec.normalized()
	
	# SET VELOCITY #
	
	# Get basis by reseting cambase x rotation to 0
	var cambase_rot_x: float = cambase.rotation_degrees.x
	cambase.rotation_degrees.x = 0
	var cambasis: Basis = cambase.basis
	cambase.rotation_degrees.x = cambase_rot_x
	
	# Normal movement if going slower than walkspeed
	var current_velocity_xz: Vector2 = Vector2(player.velocity.x, player.velocity.z)
	if current_velocity_xz.length() < vars.speed + 0.01:
		player.velocity = cambasis * Vector3(vec_normalized.x * vars.speed, player.velocity.y, vec_normalized.y * vars.speed)
	else: # Aerial movement + decelleration
		current_velocity_xz = current_velocity_xz.move_toward(Vector2.ZERO, Vector2(player.velocity.x, player.velocity.z).length() * delta * 10) # Decellerates at speed units/s
		
		player.velocity.x = current_velocity_xz.x
		player.velocity.z = current_velocity_xz.y
		
		player.velocity += cambasis * Vector3(vec_normalized.x * vars.speed * delta, 0, vec_normalized.y * vars.speed * delta)
		
