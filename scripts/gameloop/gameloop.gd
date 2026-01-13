extends Node3D

@onready var player = $player/body
@onready var hihat = $sfx/hihat
@onready var map = $map
@onready var music = $map/settings/music
@onready var spawn = $map/spawn
@onready var settings = $map/settings
@onready var ani = $player/body/visual/ani # Player AnimationPlayer


var playing = false
var hihat_juice = -1 # Acts like a timer for hihats. When it crosses a threshold, the audio plays.
var hihat_count: int = -1

var type_player = true

func _ready() -> void:
	restart()
	pass

func restart():
	hihat_juice = 0.5
	hihat_count = 2
	music.stop()
	$spawn_timer.start()
	
	
	# RESET PLAYER VARIABLES #
	
	player.position = spawn.position
	player.rotation_degrees.y = spawn.rotation_degrees.y
	print(spawn.rotation_degrees.y)
	
	
	playing = false
	$player/ui/death_ui.visible = false
	ani.play("RESET")
	player.velocity = Vector3.ZERO
	player.fuel = float($map/settings.fuel)
	$player/ui/fuel.text = str(player.fuel)
	$"player/ui/vignette_fuel".modulate.a = 0
	$player/cam_rig.rotation_degrees.y = spawn.rotation_degrees.y
	
	player.speed = 20.0
	player.jump_power = 60.0
	
	player.ability_list = []
	
	for node in $map/orbs.get_children():
		node.visible = true
		node.collider.disabled = false
	
func _process(delta: float) -> void:
	hihat_juice -= delta
	if hihat_count != 0 and hihat_count * 0.25 > hihat_juice:
		hihat_count -= 1
		$sfx/hihat.play()


func _on_spawn_timer_timeout() -> void:
	playing = true
	music.play()
