extends Node3D

@onready var player: CharacterBody3D
@onready var map: Node3D
@onready var spawn: Node3D
@onready var settings: Node
@onready var ani: AnimationPlayer # Player AnimationPlayer



var playing: bool = true
var hihat_juice: float = -1 # Acts like a timer for hihats. When it crosses a threshold, the audio plays.
var hihat_count: int = -1

var cube: PackedScene = preload("res://scenes/map_assets/cube.tscn")

func fix_variables() -> void:
	player = $player/body
	map = $map
	spawn = $map/spawn
	settings = $map/settings
	ani = $player/body/visual/ani # Player AnimationPlayer

func _ready() -> void:
	add_child(load(global.selected_map).instantiate())
	fix_variables()
	player.position = spawn.position


func _on_add_cube_pressed() -> void:
	var cube_instance: CSGBox3D = cube.instantiate()
	cube_instance.position = player.position + Vector3(0, 0, -5)
	cube_instance.position = snapped(cube_instance.position, Vector3(0.25, 0.25, 0.25))
	cube_instance.size = Vector3(3, 3, 3)
	map.add_child(cube_instance)
