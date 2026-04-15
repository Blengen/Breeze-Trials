extends Node

# Referencing Components #
@onready var vars: Node = $"../shared_variables"

# Nodes #
@onready var player: CharacterBody3D = $"../../body"
@onready var anim: AnimationPlayer = $"../../body/visual/anim"

# Ledge colliders #

@onready var ledge_colliders: Array[CollisionShape3D] = [
	$"../../body/l1",
	$"../../body/l2",
	$"../../body/l3",
	$"../../body/l4",
	$"../../body/l5",
	$"../../body/l6",
]

func jump() -> void:
	if player.is_on_floor() or vars.coyote < 0.15:
		if Input.is_action_pressed("jump"):
			player.velocity.y = vars.jump
			anim.play("jump")
			vars.coyote = 1

func quick_drop() -> void:
	if not player.is_on_floor():
		var speed: float = vars.grav * -0.5
		if player.velocity.y > speed: player.velocity.y = speed
			
func air(delta: float) -> void:
	if not player.is_on_floor():
		vars.coyote += delta
		player.velocity.y -= vars.grav * delta
	else: vars.coyote = 0
	
func ledge() -> void:
	if player.is_on_floor():
		if ledge_colliders[0].disabled:
			for child: CollisionShape3D in ledge_colliders: child.disabled = false
	elif ledge_colliders[0].disabled == false:
			for child: CollisionShape3D in ledge_colliders: child.disabled = true
