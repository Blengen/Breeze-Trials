extends Node3D

@onready var player: CharacterBody3D
@onready var map: Node3D
@onready var music: AudioStreamPlayer
@onready var spawn: Node3D
@onready var settings: Node
@onready var ani: AnimationPlayer # Player AnimationPlayer



var playing: bool = true
var hihat_juice: float = -1 # Acts like a timer for hihats. When it crosses a threshold, the audio plays.
var hihat_count: int = -1

#var type_player: bool = true

func fix_variables() -> void:
	player = $player/body
	map = $map
	music = $map/settings/music
	spawn = $map/spawn
	settings = $map/settings
	ani = $player/body/visual/ani # Player AnimationPlayer

func _ready() -> void:
	add_child(load(global.selected_map).instantiate())
	fix_variables()
	start()

func start() -> void:
	pass


func _unfocus() -> void:
	$ui/top_bar/bar.grab_focus()
