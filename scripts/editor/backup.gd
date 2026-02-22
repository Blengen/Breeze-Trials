extends Node3D

@onready var posi_x: Area3D = $"+X"
@onready var neg_x: Area3D = $"-X"
@onready var posi_y: Area3D = $"+Y"
@onready var neg_y: Area3D = $"-Y"
@onready var posi_z: Area3D = $"+Z"
@onready var neg_z: Area3D = $"-Z"

var offset: float = 3
var cam_pos: Vector3 = Vector3.ZERO

func _process(_delta: float) -> void:
	global_rotation_degrees = Vector3.ZERO
	fix_offset()

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
