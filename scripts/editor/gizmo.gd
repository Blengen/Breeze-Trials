extends Node3D

# This gizmo is a work in progress and currently not used.

@onready var posi_x: Area3D = $"+X"
@onready var neg_x: Area3D = $"-X"
@onready var posi_y: Area3D = $"+Y"
@onready var neg_y: Area3D = $"-Y"
@onready var posi_z: Area3D = $"+Z"
@onready var neg_z: Area3D = $"-Z"

var offset: float = 3
var cam_pos: Vector3 = Vector3.ZERO

var root: Node3D = self
var dragging: Vector3 = Vector3.ZERO
var drag_total: Vector3 = Vector3.ZERO
var drag_total_snapped: Vector3 = Vector3.ZERO

var drag_end: Vector3 = Vector3.ZERO

func _ready() -> void:
	while not root.is_in_group("root"): root = root.get_parent()

func _unhandled_input(event: InputEvent) -> void:
	if dragging != Vector3.ZERO and event is InputEventMouseMotion:
		if not Input.is_action_pressed("lmb"):
			dragging = Vector3.ZERO
			drag_end = drag_total
			drag_total = Vector3.ZERO
			return
		drag_total += dragging * event.relative.x * 0.01
		
		var old_value: Vector3 = drag_total_snapped
		drag_total_snapped = snapped(drag_total, Vector3(0.25, 0.25, 0.25))
		if not old_value == drag_total_snapped: print(drag_total_snapped)

func _process(_delta: float) -> void:
	global_rotation_degrees = Vector3.ZERO
	fix_offset()
	if dragging: hide()
	else: show()
	#print(dragging)

func fix_offset() -> void:
	if cam_pos == global.cam_pos: return
	cam_pos = global.cam_pos
	
	offset = cam_pos.distance_to(global_position) * 0.4
	
	posi_x.position.x = offset
	neg_x.position.x = -offset
	posi_y.position.y = offset
	neg_y.position.y = -offset
	posi_z.position.z = offset
	neg_z.position.z = -offset
	
	var new_size: float = offset * 0.15
	for child in get_children(): child.scale = Vector3(new_size, new_size, new_size)

func _on_handle_input(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int, axis: Vector3) -> void:
	if root == self: return
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed and root.selected: dragging = axis


func _posi_x(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void: _on_handle_input(camera, event, event_position, normal, shape_idx, Vector3(1, 0, 0)) 
func _posi_y(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void: _on_handle_input(camera, event, event_position, normal, shape_idx, Vector3(0, 1, 0))
func _posi_z(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void: _on_handle_input(camera, event, event_position, normal, shape_idx, Vector3(0, 0, 1))
func _neg_x(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void: _on_handle_input(camera, event, event_position, normal, shape_idx, Vector3(1, 0, 0))
func _neg_y(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void: _on_handle_input(camera, event, event_position, normal, shape_idx, Vector3(0, 1, 0))
func _neg_z(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void: _on_handle_input(camera, event, event_position, normal, shape_idx, Vector3(0, 0, 1))
