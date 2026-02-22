extends Node3D

@onready var player: CharacterBody3D
@onready var hihat: AudioStreamPlayer
@onready var map: Node3D
@onready var music: AudioStreamPlayer
@onready var spawn: Node3D
@onready var settings: Node
@onready var ani: AnimationPlayer # Player AnimationPlayer
@onready var death_ui: Control
@onready var spawn_timer: Timer


var playing: bool = false
var hihat_juice: float = -1 # Acts like a timer for hihats. When it crosses a threshold, the audio plays.
var hihat_count: int = -1

var music_dir: String = "res://scenes/Whimsical Ahh Belenge beat.mp3"

#var type_player: bool = true

func fix_variables() -> void:
	player = $player/body
	hihat = $sfx/hihat
	map = $map
	music = $map/settings/music
	spawn = $map/spawn
	settings = $map/settings
	ani = $player/body/visual/ani # Player AnimationPlayer
	death_ui = $player/ui/death_ui
	spawn_timer = $spawn_timer

func get_song() -> void:
	music_dir = global.selected_map.get_base_dir().path_join(settings.music_file)
	if music_dir != global.selected_map.get_base_dir() + "/": music.stream = load(music_dir)
	
	music.volume_linear = 1.0
	music.volume_linear *= (settings.music_volume / 100.0) * (global.music_volume / 100.0)

func fix_pause_menu() -> void:
	$pause_menu/VBoxContainer/music.text = "Music: " + settings.music_name
	$pause_menu/VBoxContainer/composer.text = "By " + settings.composer
	$pause_menu/VBoxContainer/license.text = "License: " + settings.license

func _ready() -> void:
	add_child(load(global.selected_map).instantiate())
	fix_variables()
	get_song()
	fix_pause_menu()
	restart()
	
	

func restart() -> void:
	hihat_juice = 0.5
	hihat_count = 2
	music.stop()
	spawn_timer.start()
	$"player/ui/vignette_fuel".show()
	
	
	# RESET PLAYER VARIABLES #
	
	player.position = spawn.position
	player.rotation_degrees.y = spawn.rotation_degrees.y
	
	
	playing = false
	death_ui.visible = false
	ani.play("RESET")
	player.velocity = Vector3.ZERO
	player.fuel = float($map/settings.fuel)
	$player/ui/fuel.text = str(player.fuel)
	$"player/ui/vignette_fuel".modulate.a = 0
	$player/cam_rig.rotation_degrees.y = spawn.rotation_degrees.y
	
	player.speed = 20.0
	player.jump_power = 60.0
	
	player.ability_list = []
	player.debug = false
	player.flying = false
	
	$sfx/hihat.play()
	$"2nd_hihat_timer".start()
	
	for node in $map/orbs.get_children():
		node.visible = true
		node.collider.disabled = false

func _on_spawn_timer_timeout() -> void:
	playing = true
	music.play()
	

func _on_2nd_hihat_timer_timeout() -> void:
	$sfx/hihat.play()
