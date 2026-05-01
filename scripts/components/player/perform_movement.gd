extends Node

@onready var player: CharacterBody3D = $"../../body"
var use_phyics_process: bool = global.use_physics_process

func _process(_delta: float) -> void:
	if player.velocity: player.move_and_slide()
