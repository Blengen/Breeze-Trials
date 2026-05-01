extends Node

# MAP_INFO #
@export var map_name: String = ""
@export var map_difficulty: float = 2

# MUSIC_INFO #
@export var music_name: String = ""
@export var music_file: String = ".mp3"
@export var music_composer: String = ""
@export var music_license: String = "CC"

# GAME SETTINGS #
@export var starting_speed: float = 20
@export var starting_jump: float = 60
@export var starting_grav: float = 250

@export var starting_fuel: float = 5

@onready var music_node: AudioStreamPlayer = $music

func _ready() -> void:
	if !music_file: return # No music to play
	var music_path: String = global.selected_map
	music_path = music_path.get_base_dir()
	music_path = music_path.path_join(music_file)
	print(music_path)
	
	
	music_node.stream = load(music_path)
	
	global.restart.connect(func() -> void: music_node.playing = false)
	global.begin.connect(func() -> void: music_node.playing = true)
	
	settings.settings_changed.connect(update)
	update()
	
func update() -> void:
	music_node.pitch_scale = Engine.time_scale
