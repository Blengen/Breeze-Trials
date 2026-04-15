extends Node

func _ready() -> void:
	
	var root: Node = self
	while not root.is_in_group("root"): root = root.get_parent()
	
	var map_instance: Node3D = load(global.selected_map).instantiate()
	root.add_child.call_deferred(map_instance)
