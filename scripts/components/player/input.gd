extends Node

# COMPONENTS #
@onready var camera: Node = $"../camera"
@onready var move_y: Node = $"../move_y"
@onready var ability: Node = $"../ability"

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion: camera.turn_camera(event)
	
	elif event is InputEventKey or InputEventMouseButton:
		
		# Camera keys
		if event.is_action_pressed("camlock"): camera.camlock()
		
		# Player keys
		if event.is_action_pressed("quick_drop"): move_y.quick_drop()
		
		# Camera keys
		if event.is_action_pressed("zoom_in"): camera.zoom(-2.5)
		elif event.is_action_pressed("zoom_out"): camera.zoom(2.5)
		
		
