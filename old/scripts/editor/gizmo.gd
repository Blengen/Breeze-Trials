extends Node3D

var root: Node = self

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and Input.is_action_just_pressed("gizmo"):
		$"move&size".visible = !$"move&size".visible
		$rotate.visible = !$rotate.visible

func _ready() -> void:
	while not root.is_in_group("root"): root = root.get_parent()

func _process(_delta: float) -> void:
	var new_scale: float = global_position.distance_to(root.player.cam.global_position) * 0.05
	scale = Vector3(new_scale, new_scale, new_scale)
	
	if root.selected:
		show()
		global_position = root.selected.global_position
	else: hide()

func _on_movesize_visibility_changed() -> void:
	if $"move&size".visible:
		$"move&size/move/+X/CollisionShape3D".disabled = false
		$"move&size/move/+Y/CollisionShape3D".disabled = false
		$"move&size/move/+Z/CollisionShape3D".disabled = false
		$"move&size/move/-X/CollisionShape3D".disabled = false
		$"move&size/move/-Y/CollisionShape3D".disabled = false
		$"move&size/move/-Z/CollisionShape3D".disabled = false

		$"move&size/size/+X/CollisionShape3D".disabled = false
		$"move&size/size/+Y/CollisionShape3D".disabled = false
		$"move&size/size/+Z/CollisionShape3D".disabled = false
		$"move&size/size/-X/CollisionShape3D".disabled = false
		$"move&size/size/-Y/CollisionShape3D".disabled = false
		$"move&size/size/-Z/CollisionShape3D".disabled = false
	else:
		$"move&size/move/+X/CollisionShape3D".disabled = true
		$"move&size/move/+Y/CollisionShape3D".disabled = true
		$"move&size/move/+Z/CollisionShape3D".disabled = true
		$"move&size/move/-X/CollisionShape3D".disabled = true
		$"move&size/move/-Y/CollisionShape3D".disabled = true
		$"move&size/move/-Z/CollisionShape3D".disabled = true

		$"move&size/size/+X/CollisionShape3D".disabled = true
		$"move&size/size/+Y/CollisionShape3D".disabled = true
		$"move&size/size/+Z/CollisionShape3D".disabled = true
		$"move&size/size/-X/CollisionShape3D".disabled = true
		$"move&size/size/-Y/CollisionShape3D".disabled = true
		$"move&size/size/-Z/CollisionShape3D".disabled = true

func _on_rotate_visibility_changed() -> void:
	if $rotate.visible:
		$rotate/X/CollisionShape3D.disabled = false
		$rotate/Y/CollisionShape3D.disabled = false
		$rotate/Z/CollisionShape3D.disabled = false
	else:
		$rotate/X/CollisionShape3D.disabled = true
		$rotate/Y/CollisionShape3D.disabled = true
		$rotate/Z/CollisionShape3D.disabled = true
