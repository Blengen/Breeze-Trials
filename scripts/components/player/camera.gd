extends Node

# Nodes #
@onready var cam: Camera3D = $"../../cambase/cam"
@onready var cambase: Node3D = $"../../cambase"
@onready var visual: Node3D = $"../../body/visual"

# COMPONENTS #
@onready var vars: Node = $"../shared_variables"

# Variables
var sens: float = global.sens

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func turn_camera(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if !vars.camlock and not (Input.is_action_pressed("rmb") or cam.position.z == 0): return
		cambase.rotation_degrees.y -= event.relative.x * sens
		cambase.rotation_degrees.x -= event.relative.y * sens
		
		if cambase.rotation_degrees.x > 90: cambase.rotation_degrees.x = 90
		elif cambase.rotation_degrees.x < -90: cambase.rotation_degrees.x = -90

func camlock() -> void: vars.camlock = !vars.camlock
	
func zoom(amount: float) -> void:
	cam.position.z += amount
	cam.position.z = clamp(cam.position.z, 0, 50)
	if cam.position.z == 0: visual.hide()
	else: visual.show()
