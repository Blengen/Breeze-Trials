extends Node

# Nodes #
@onready var cam: Camera3D = $"../../cambase/cam"
@onready var cambase: Node3D = $"../../cambase"
@onready var player: CharacterBody3D = $"../../body"
@onready var visual: Node3D = $"../../body/visual"
@onready var camlock_ui: TextureRect = $camlock

# COMPONENTS #
@onready var vars: Node = $"../shared_variables"

# Variables
var sens: float = settings.sens

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	# Will crash if not in the ingame scene. Checks needed for future scenes.
	$"../../../components/pause_handler/pause_ui/settings/menu_maker/logic_handler".settings_changed.connect(fix_fov)

func fix_fov() -> void:
	cam.fov = settings.fov

func turn_camera(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		 # Bunch of specific checks to see if the camera should be turned with the mouse movement or not
		if (!vars.camlock or get_tree().paused) and not (Input.is_action_pressed("rmb") or cam.position.z == 0): return
		
		cambase.rotation_degrees.y -= event.relative.x * sens
		cambase.rotation_degrees.x -= event.relative.y * sens
		
		if cambase.rotation_degrees.x > 90: cambase.rotation_degrees.x = 90
		elif cambase.rotation_degrees.x < -90: cambase.rotation_degrees.x = -90

func camlock() -> void:
	vars.camlock = !vars.camlock
	#camlock_ui.visible = vars.camlock

	
func zoom(amount: float) -> void:
	cam.position.z += amount
	cam.position.z = clamp(cam.position.z, 0, 50)
	if cam.position.z == 0: visual.hide()
	else: visual.show()

func align() -> void:
	cambase.position = player.position + Vector3(0, 1.5, 0)
	if not cam.position.z == 0 and vars.camlock: cam.position.x = 1
	else: cam.position.x = 0
	
