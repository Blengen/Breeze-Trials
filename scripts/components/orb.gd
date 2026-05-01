extends Area3D

@export var type: String = "none"
@export var value: float = 0

@onready var sprite: Sprite3D = $sprite
@onready var collider: CollisionShape3D = $collider
@onready var timer: Timer = $timer

@onready var player_vars: Node = null

func _ready() -> void:

	if not body_entered.is_connected(_body_entered): connect("body_entered", _body_entered)
	if not timer.timeout.is_connected(_timeout): timer.connect("timeout", _timeout)
	
	await get_tree().process_frame
	await get_tree().process_frame
	
	player_vars = $"../../../player/components/shared_variables"
	load_texture()
	
func load_texture() -> void:
	match type:
		"dash": sprite.texture = preload("res://assets/textures/orbs/dash.png")
		"jump": sprite.texture = preload("res://assets/textures/orbs/jump.png")
		"stat_speed":
			if player_vars.speed > value: sprite.texture = preload("res://assets/textures/orbs/stat_speed_minus.png")
			else: sprite.texture = preload("res://assets/textures/orbs/stat_speed.png")
		"stat_jump":
			if player_vars.jump > value: sprite.texture = preload("res://assets/textures/orbs/stat_jump_minus.png")
			else: sprite.texture = preload("res://assets/textures/orbs/stat_jump.png")
		"fuel": sprite.texture = preload("res://assets/textures/orbs/fuel.png")
		"end": sprite.texture = preload("res://assets/textures/orbs/end.png")
		_: sprite.texture = preload("res://assets/textures/orbs/none.png")

func _body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		var ability_component: Node = body.get_parent().get_child(0).get_child(0)

		ability_component.orb_hit(self)

func _timeout() -> void:
	show()
	$collider.disabled = false
