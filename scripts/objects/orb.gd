extends Area3D

@onready var collider: CollisionShape3D = $collider
@onready var timer: Timer = $timer
@onready var sprite: Sprite3D = $sprite

@export var type: String = "none"
@export var value: float = 0



const type_orb: bool = true

func _ready() -> void:
	match type:
		"dash": sprite.texture = load("res://images/orb_icons/dash.png")
		"jump": sprite.texture = load("res://images/orb_icons/jump.png")
		"stat_speed": sprite.texture = load("res://images/orb_icons/stat_speed.png")
		"stat_jump": sprite.texture = load("res://images/orb_icons/stat_jump.png")
		"fuel": sprite.texture = load("res://images/orb_icons/fuel.png")
		"end": sprite.texture = load("res://images/orb_icons/end.png")

func _on_timer_timeout() -> void:
	visible = true
	collider.disabled = false
