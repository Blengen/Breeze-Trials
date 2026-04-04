extends Node3D

# Me when I lowkey can't write clean code and I get DeepSeek to refactor everything

# ============================================================
# NODE REFERENCES
# ============================================================
@onready var player: CharacterBody3D
@onready var map: Node3D
@onready var main: Node3D
@onready var spawn: Node3D
@onready var settings: Node
@onready var ani: AnimationPlayer
@onready var cline: LineEdit = $ui/cline

# ============================================================
# EDITOR STATE
# ============================================================
var selected: Node

# Gizmo scene
@onready var gizmo: Node3D = $gizmo

# Gizmo transform state
var gizmove: bool = false
var gizmove_type: String = "move"
var gizmove_dir: Vector3 = Vector3(1, 0, 0)
var gizmove_start: float = 0.0
var gizmove_origin: Vector3 = Vector3.ZERO
var gizmove_pos: Vector3 = Vector3.ZERO
var gizmove_rot: Vector3 = Vector3.ZERO
var gizmove_size: Vector3 = Vector3.ZERO
var gizmove_scale: Vector3 = Vector3.ZERO

# Transformation settings
const MOVE_SENSITIVITY: float = 0.1
const SIZE_SENSITIVITY: float = 0.05
const SCALE_SENSITIVITY: float = 0.05
const ROTATION_SENSITIVITY: float = 1.0
const EVEN_OFFSET_SENSITIVITY: float = 0.025

var increment: Vector3 = Vector3(1, 1, 1)
var rotation_increment: float = 22.5

# Legacy transform mode (keyboard-based)
var transform_mode: String = "move"          # "move", "size", "rotate"
var transform_dir: String = "x"              # "x", "y", "z"
var transforming: bool = false
var transform_x: float = 0
var transform_y: float = 0
var origin: Vector3 = Vector3.ZERO
var transform_object: Node = null

# Map saving
var save_scene: Variant = null
var playing: bool = true
var hihat_juice: float = -1
var hihat_count: int = -1

# Materials lookup
var materials: Dictionary = {
	# Normal Colors
	"red": preload("res://materials/colors/standard/red.tres"),
	"flame": preload("res://materials/colors/standard/flame.tres"),
	"orange": preload("res://materials/colors/standard/orange.tres"),
	"yellow": preload("res://materials/colors/standard/yellow.tres"),
	"lime": preload("res://materials/colors/standard/lime.tres"),
	"green": preload("res://materials/colors/standard/green.tres"),
	"l_blue": preload("res://materials/colors/standard/l_blue.tres"),
	"blue": preload("res://materials/colors/standard/blue.tres"),
	"purple": preload("res://materials/colors/standard/purple.tres"),
	"pink": preload("res://materials/colors/standard/pink.tres"),
	# Dark colors
	"dark_red": preload("res://materials/colors/dark/dark_red.tres"),
	"dark_flame": preload("res://materials/colors/dark/dark_flame.tres"),
	"dark_orange": preload("res://materials/colors/dark/dark_orange.tres"),
	"dark_yellow": preload("res://materials/colors/dark/dark_yellow.tres"),
	"dark_lime": preload("res://materials/colors/dark/dark_lime.tres"),
	"dark_green": preload("res://materials/colors/dark/dark_green.tres"),
	"dark_l_blue": preload("res://materials/colors/dark/dark_l_blue.tres"),
	"dark_blue": preload("res://materials/colors/dark/dark_blue.tres"),
	"dark_purple": preload("res://materials/colors/dark/dark_purple.tres"),
	"dark_pink": preload("res://materials/colors/dark/dark_pink.tres"),
	# Pale colors
	"pale_red": preload("res://materials/colors/pale/pale_red.tres"),
	"pale_flame": preload("res://materials/colors/pale/pale_flame.tres"),
	"pale_orange": preload("res://materials/colors/pale/pale_orange.tres"),
	"pale_yellow": preload("res://materials/colors/pale/pale_yellow.tres"),
	"pale_lime": preload("res://materials/colors/pale/pale_lime.tres"),
	"pale_green": preload("res://materials/colors/pale/pale_green.tres"),
	"pale_l_blue": preload("res://materials/colors/pale/pale_l_blue.tres"),
	"pale_blue": preload("res://materials/colors/pale/pale_blue.tres"),
	"pale_purple": preload("res://materials/colors/pale/pale_purple.tres"),
	"pale_pink": preload("res://materials/colors/pale/pale_pink.tres"),
	# Textures
	"brick": preload("res://materials/textures/brick.tres"),
	"cobble": preload("res://materials/textures/cobble.tres"),
	"dirt": preload("res://materials/textures/dirt.tres"),
	"ground": preload("res://materials/textures/ground.tres"),
	"grass": preload("res://materials/textures/grass.tres"),
	"metal_plate": preload("res://materials/textures/metal_plate.tres"),
	"sand": preload("res://materials/textures/sand.tres"),
	"stone_brick": preload("res://materials/textures/stone_brick.tres"),
	"wood_rough": preload("res://materials/textures/wood_rough.tres"),
	# Other
	"hidden": preload("res://materials/other/hidden.tres"),
	"white": preload("res://materials/other/white.tres"),
	"l_gray": preload("res://materials/other/l_gray.tres"),
	"gray": preload("res://materials/other/gray.tres"),
	"d_gray": preload("res://materials/other/d_gray.tres"),
	"black": preload("res://materials/other/black.tres"),
}

# Selection material
var selection_material: StandardMaterial3D = preload("res://materials/selection.tres")

# ============================================================
# INITIALIZATION
# ============================================================
func _ready() -> void:
	load_map()
	fix_variables()
	player.position = spawn.position

func load_map() -> void:
	add_child(load(global.selected_map).instantiate())

func fix_variables() -> void:
	player = $player/body
	map = $map
	main = $map/main
	spawn = $map/spawn
	settings = $map/settings
	ani = $player/body/visual/ani

# ============================================================
# UI BUTTON CALLBACKS
# ============================================================
func _on_add_cube_pressed() -> void:
	var cube_instance: CSGBox3D = CSGBox3D.new()
	cube_instance.position = player.position + Vector3(0, -1, -5)
	cube_instance.position = snapped(cube_instance.position, Vector3(1, 1, 1))
	cube_instance.size = Vector3(3, 3, 3)
	cube_instance.use_collision = true
	cube_instance.collision_layer = 5
	cube_instance.material_override = materials["gray"]
	main.add_child(cube_instance)
	cube_instance.owner = map

func _on_add_other_pressed() -> void:
	_on_add_orb_pressed() # Temporary

func _on_add_orb_pressed() -> void:
	var orb_instance: Area3D = load("res://scenes/ingame/orb.tscn").instantiate()
	orb_instance.position = player.position + Vector3(0, -1, -5)
	orb_instance.position = snapped(orb_instance.position, Vector3(1, 1, 1))
	$map/orbs.add_child(orb_instance)
	orb_instance.owner = map

func _on_add_cylinder_pressed() -> void:
	var cylinder_instance: CSGCylinder3D = CSGCylinder3D.new()
	cylinder_instance.position = player.position + Vector3(0, -1, -5)
	cylinder_instance.position = snapped(cylinder_instance.position, Vector3(1, 1, 1))
	cylinder_instance.radius = 3
	cylinder_instance.height = 3
	cylinder_instance.use_collision = true
	cylinder_instance.collision_layer = 1 | 3
	cylinder_instance.sides = 16
	cylinder_instance.smooth_faces = false
	main.add_child(cylinder_instance)
	cylinder_instance.owner = map

func _on_add_low_poly_rock_pressed() -> void:
	pass # Placeholder

func _on_lock_cursor_pressed() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	$"ui/top_bar/items_middle/1".text = "ESC to return"
	if selected:
		selected.material_overlay = null
		for child in selected.get_children():
			if child.is_in_group("gizmo"):
				child.queue_free()
	selected = null

func _on_mode_pressed() -> void:
	if transform_mode == "move":
		$"ui/top_bar/items_middle/3".text = "Scaling"
		transform_mode = "size"
	elif $"ui/top_bar/items_middle/3".text == "Scaling":
		$"ui/top_bar/items_middle/3".text = "Rotating"
		transform_mode = "rotate"
	elif $"ui/top_bar/items_middle/3".text == "Rotating":
		$"ui/top_bar/items_middle/3".text = "Moving"
		transform_mode = "move"

func _on_save_as_pressed() -> void:
	save_scene = PackedScene.new()
	var err: Error = save_scene.pack($map)
	if err == OK:
		$save_dialog.show()
	else:
		print_error("Something went wrong while saving: " + str(err))
	$"ui/top_bar/items_right/4".disabled = false
	$"ui/top_bar/items_right/4/disable_timer".start()

func _on_save_pressed() -> void:
	
	# Pack the map first
	save_scene = PackedScene.new()
	var err: Error = save_scene.pack($map)
	if err != OK:
		print_error("Something went wrong with packing the map for save: " + str(err))
		return
		
	if global.selected_map.ends_with(".btmap.tscn") and not global.selected_map.begins_with("res://"):
		err = ResourceSaver.save(save_scene, global.selected_map)
		if err != OK: print_error("Map did not save properly: " + str(err))
	else: _on_save_as_pressed() # Save as if it's the wrong file type

func _on_file_dialog_file_selected(path: String) -> void:
	if not path.ends_with(".btmap.tscn"):
		path += ".btmap.tscn"
	var err: Error = ResourceSaver.save(save_scene, path)
	if err != OK:
		print_error("Map did not save properly: " + str(err))
	global.selected_map = path

func _on_disable_timer_timeout() -> void:
	$"ui/top_bar/items_right/3".disabled = true

func _on_exit_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu/main_menu.tscn")

# ============================================================
# OBJECT SELECTION
# ============================================================
func selection(object: Node) -> void:
	# Clear previous selection highlight
	if selected is CSGShape3D:
		selected.material_overlay = null
	elif selected is Area3D and selected.is_in_group("orb"):
		selected.sprite.modulate = Color(1, 1, 1)
	if selected:
		for child in selected.get_children():
			if child.is_in_group("gizmo"):
				child.queue_free()
	selected = null

	if object:
		selected = object

		if object is CSGShape3D:
			object.material_overlay = selection_material
		elif selected is Area3D and selected.is_in_group("orb"):
			selected.sprite.modulate = Color(0.5, 0.5, 0.5)

# ============================================================
# GIZMO TRANSFORM HANDLING (New)
# ============================================================
func _process(_delta: float) -> void:
	if not gizmove:
		return

	_update_increments()

	if not Input.is_action_pressed("lmb"):
		gizmove = false
		return

	var mouse_y: float = get_viewport().get_mouse_position().y
	var delta_y: float = mouse_y - gizmove_start

	match gizmove_type:
		"move": _apply_move(delta_y)
		"size": _apply_size(delta_y)
		"scale": _apply_scale(delta_y)
		"rotate": _apply_rotation(delta_y)

func _update_increments() -> void:
	if Input.is_action_pressed("increment_small"):
		increment = Vector3(0.25, 0.25, 0.25)
		rotation_increment = 5.0
	elif Input.is_action_pressed("increment_smaller"):
		increment = Vector3(0.05, 0.05, 0.05)
		rotation_increment = 2.5
	else:
		increment = Vector3(1.0, 1.0, 1.0)
		rotation_increment = 22.5

func _apply_move(delta: float) -> void:
	var movement: Vector3 = -delta * MOVE_SENSITIVITY * gizmove_dir
	var new_pos: Vector3 = gizmove_origin + movement
	selected.position = snapped(new_pos, increment * gizmove_dir)

func _apply_size(delta: float) -> void:
	var delta_size: Vector3 = -delta * SIZE_SENSITIVITY * abs(gizmove_dir)
	var new_size: Vector3 = gizmove_origin + delta_size
	new_size = snapped(new_size, increment)
	new_size.x = max(new_size.x, increment.x)
	new_size.y = max(new_size.y, increment.y)
	new_size.z = max(new_size.z, increment.z)
	selected.size = new_size

	if Input.is_action_pressed("even"):
		selected.position = gizmove_pos
	else:
		var offset: Vector3 = -delta * EVEN_OFFSET_SENSITIVITY * gizmove_dir
		var new_pos: Vector3 = gizmove_pos + offset
		selected.position = snapped(new_pos, increment * 0.5 * gizmove_dir)

func _apply_scale(delta: float) -> void:
	if selected.is_in_group("orb"):
		return

	var delta_scale: Vector3 = -delta * SCALE_SENSITIVITY * abs(gizmove_dir)
	var new_scale: Vector3 = gizmove_origin + delta_scale
	new_scale = snapped(new_scale, increment)
	new_scale.x = max(new_scale.x, increment.x)
	new_scale.y = max(new_scale.y, increment.y)
	new_scale.z = max(new_scale.z, increment.z)
	selected.scale = new_scale

	if Input.is_action_pressed("even"):
		selected.position = gizmove_pos
	else:
		var offset: Vector3 = -delta * EVEN_OFFSET_SENSITIVITY * gizmove_dir
		var new_pos: Vector3 = gizmove_pos + offset
		selected.position = snapped(new_pos, increment * 0.5 * gizmove_dir)

func _apply_rotation(delta: float) -> void:
	var rotation_delta: Vector3 = -delta * ROTATION_SENSITIVITY * gizmove_dir
	var new_rot: Vector3 = gizmove_origin + rotation_delta
	new_rot = snapped(new_rot, Vector3(rotation_increment, rotation_increment, rotation_increment) * gizmove_dir)
	selected.rotation_degrees = new_rot

func start_gizmo_transform(type: String, dir: Vector3, start_mouse_y: float) -> void:
	if not selected:
		return

	gizmove = true
	gizmove_type = type
	gizmove_dir = dir
	gizmove_start = start_mouse_y

	# Store original values
	gizmove_pos = selected.position
	gizmove_rot = selected.rotation_degrees
	if selected.has_method("get_size") or selected is CSGShape3D:
		gizmove_size = selected.size
	gizmove_scale = selected.scale

	match type:
		"move":
			gizmove_origin = selected.position
		"size":
			gizmove_origin = selected.size
		"scale":
			gizmove_origin = selected.scale
		"rotate":
			gizmove_origin = selected.rotation_degrees

# Called from gizmo input signals
func gizmo_transform(groups: Array) -> void:
	var type: String = "move"
	var dir: Vector3 = Vector3(1, 0, 0)

	if groups.has(&"size"):
		type = "size"
	elif groups.has(&"rotate"):
		type = "rotate"

	if groups.has(&"y"):
		dir = Vector3.UP
	elif groups.has(&"z"):
		dir = Vector3(0, 0, 1)

	if groups.has(&"-"):
		dir *= -1

	start_gizmo_transform(type, dir, get_viewport().get_mouse_position().y)

# ============================================================
# LEGACY KEYBOARD TRANSFORM (keep for compatibility)
# ============================================================
func _unhandled_input(event: InputEvent) -> void:
	# Cancel transform if all transform keys released
	if transforming:
		if not Input.is_action_pressed("transform_xz") and not Input.is_action_pressed("transform_y") and not Input.is_action_pressed("transform_z"):
			transforming = false
			transform_x = 0
			transform_y = 0
			transform_object = null

	if event is InputEventMouseMotion and transforming and transform_object:
		transform_x += event.relative.x
		transform_y += event.relative.y
		update_transform()

	if event is InputEventKey:
		if (selected or transform_object) and Input.is_action_just_pressed("transform_xz"):
			start_transform("x")
		elif (selected or transform_object) and Input.is_action_just_pressed("transform_y"):
			start_transform("y")
		elif (selected or transform_object) and Input.is_action_just_pressed("transform_z"):
			start_transform("z")

		if Input.is_action_just_pressed("duplicate"):
			_on_cline_text_submitted("dup")

func start_transform(dir: String) -> void:
	transform_dir = dir
	transforming = true
	transform_object = selected
	set_origin()

func set_origin() -> void:
	match transform_mode:
		"move":
			origin = transform_object.position
		"size":
			if selected is CSGShape3D:
				origin = transform_object.size
		"rotate":
			origin = transform_object.rotation_degrees

func update_transform() -> void:
	# Determine increment (already updated elsewhere, but ensure consistency)
	_update_increments()

	match transform_dir:
		"x":
			if transform_mode == "move":
				transform_object.position = origin + snapped(Vector3(transform_x * 0.05, 0, transform_y * 0.05), increment)
			elif transform_mode == "size" and transform_object is CSGShape3D:
				transform_object.size = origin + snapped(Vector3(transform_x * 0.05, 0, transform_y * 0.05), increment)
				if transform_object.size.x < increment.x:
					transform_object.size.x = increment.x
				if transform_object.size.z < increment.z:
					transform_object.size.z = increment.z
			elif transform_mode == "rotate":
				transform_object.rotation_degrees.x = origin.x - snappedf(transform_y, rotation_increment)

		"y":
			if transform_mode == "move":
				transform_object.position.y = origin.y + snappedf(-transform_y * 0.05, increment.x)
			elif transform_mode == "size" and transform_object is CSGBox3D:
				transform_object.size.y = origin.y + snappedf(-transform_y * 0.05, increment.x)
				if transform_object.size.y < increment.y:
					transform_object.size.y = increment.y
			elif transform_mode == "rotate":
				transform_object.rotation_degrees.y = origin.y + snappedf(transform_x, rotation_increment)

		"z":
			if transform_mode == "rotate":
				transform_object.rotation_degrees.z = origin.z + snappedf(transform_y, rotation_increment)

# ============================================================
# COMMAND LINE PARSER
# ============================================================
func _on_cline_text_submitted(cmd: String) -> void:
	cline.text = ""
	cmd = cmd.to_lower().strip_edges()
	var args: Array = cmd.split(" ", false)
	if args.is_empty():
		return

	var command: String = args[0]
	var rest: Array = args.slice(1)

	if command.begins_with("pos") or command.begins_with("size") or command.begins_with("rot"):
		handle_transform_command(command, rest)
		return

	match command:
		"mat", "material":
			handle_material_command(rest)
		"col", "collide", "cancollide", "collision", "hascollision":
			handle_collision_command(rest)
		"matlist", "materials", "mats", "passmethelistofmaterialsalready":
			print_material_list()
		"help", "cmds", "cmd":
			print_help()
		"dupe", "dup", "copy", "duplicate":
			handle_duplicate()
		"del", "delete", "remove", "destroy":
			handle_delete()
		"orb", "orbsettings":
			handle_orb_settings(args)
		"spawn":
			spawn.position = player.position
		_:
			print_error("Unknown command: " + command)

func handle_transform_command(cmd: String, args: Array) -> void:
	if not selected:
		print_error("No object selected")
		return

	var base: String
	var axis: String = ""
	var operator: String = ""

	# Extract base, axis, operator
	if cmd.begins_with("size"):
		base = "size"
		var suffix: String = cmd.trim_prefix("size")
		var parsed: Array = parse_suffix(suffix)
		axis = parsed[0]
		operator = parsed[1]
	elif cmd.begins_with("pos"):
		base = "pos"
		var suffix: String = cmd.trim_prefix("pos")
		var parsed: Array = parse_suffix(suffix)
		axis = parsed[0]
		operator = parsed[1]
	elif cmd.begins_with("rot"):
		base = "rot"
		var suffix: String = cmd.trim_prefix("rot")
		var parsed: Array = parse_suffix(suffix)
		axis = parsed[0]
		operator = parsed[1]
	else:
		return

	# Get the property to modify based on base
	var prop: Variant
	match base:
		"size":
			if not (selected is CSGShape3D):
				print_error("Selected object does not support size")
				return
			prop = selected.size
		"pos":
			prop = selected.position
		"rot":
			prop = selected.rotation_degrees

	# Determine number of arguments needed
	var expected_args: int = 3 if axis == "" else 1
	if args.size() != expected_args:
		print_error("Expected " + str(expected_args) + " arguments, got " + str(args.size()))
		return

	# Convert arguments to floats
	var values: Array[float] = []
	for a: String in args:
		if a.is_valid_float():
			values.append(float(a))
		else:
			print_error("Invalid number: " + a)
			return

	# Apply the change
	if axis == "":
		var new_vec: Vector3
		if operator == "+":
			new_vec = prop + Vector3(values[0], values[1], values[2])
		else:
			new_vec = Vector3(values[0], values[1], values[2])
		apply_transform(base, new_vec)
	else:
		var idx: int = {"x": 0, "y": 1, "z": 2}[axis]
		var delta: float = values[0]
		var new_val: float = prop[idx] + delta if operator == "+" else delta
		var new_vec: Variant = prop
		new_vec[idx] = new_val
		apply_transform(base, new_vec)

func parse_suffix(suffix: String) -> Array:
	var axis: String = ""
	var operator: String = ""

	if "x" in suffix: axis = "x"
	elif "y" in suffix: axis = "y"
	elif "z" in suffix: axis = "z"

	if "+" in suffix: operator = "+"
	elif "-" in suffix: operator = "-"
	elif "*" in suffix: operator = "*"
	elif "/" in suffix: operator = "/"

	return [axis, operator]

func apply_transform(base: String, new_val: Vector3) -> void:
	match base:
		"size":
			selected.size = new_val
			if selected.size.x < 0.1: selected.size.x = 0.1
			if selected.size.y < 0.1: selected.size.y = 0.1
			if selected.size.z < 0.1: selected.size.z = 0.1
		"pos":
			selected.position = new_val
		"rot":
			selected.rotation_degrees = new_val

func handle_material_command(args: Array) -> void:
	if not selected:
		print_error("No object selected")
		return
	if args.size() != 1:
		print_error("Expected 1 argument (material name)")
		return
	var mat_name: String = args[0]
	if not materials.has(mat_name):
		print_error("Invalid material name. Use 'matlist' to see names.")
		return
	selected.material_override = materials[mat_name]

func handle_collision_command(args: Array) -> void:
	if not selected:
		print_error("No object selected")
		return
	if args.is_empty():
		selected.collision_layer = 5 if selected.collision_layer == 4 else 4
	else:
		var arg: String = args[0].to_lower()
		if arg == "true":
			selected.collision_layer = 5
		elif arg == "false":
			selected.collision_layer = 4
		else:
			print_error("Usage: col [true/false] (omit to toggle)")

func print_material_list() -> void:
	var msg: String = "Colors: red, flame, orange, yellow, lime, green, l_blue, blue, purple, pink.\n"
	msg += "Dark and pale variants (\"dark_red\").\n"
	msg += "Textures: brick, stone_brick, cobble, dirt, ground, grass, metal_plate, sand, wood_rough.\n"
	msg += "Other: hidden, white, l_gray, gray, d_gray, black"
	print_error(msg)

func print_help() -> void:
	var msg: String = "size, sizex, sizey, sizez, size+, sizex+, sizey+, sizez+ - same with pos/rot.\n"
	msg += "col [true/false] - toggle collision.\n"
	msg += "mat <name> - set material.\n"
	msg += "matlist - list materials.\n"
	msg += "dupe - duplicate selected.\n"
	msg += "del - delete selected."
	print_error(msg)

func handle_duplicate() -> void:
	if not selected:
		print_error("No object selected")
		return

	var duplicated: Node = selected.duplicate()
	selected.get_parent().add_child(duplicated)
	if not selected.is_in_group("orb"):
		selected.material_overlay = null
	selected = duplicated
	duplicated.owner = map


func handle_delete() -> void:
	if not selected:
		print_error("No object selected")
		return
	selected.queue_free()
	selected = null

func handle_orb_settings(args: Array) -> void:
	if not selected or not selected.is_in_group("orb"):
		print_error("No orb selected")
		return
	if args.size() != 3:
		print_error("Expected 2 arguments (orb type, strength), got " + str(args.size() - 1))
		return
	if ["dash", "jump", "stat_speed", "stat_jump", "fuel", "end"].has(args[1]):
		selected.type = args[1]
	if args[2].is_valid_float():
		selected.value = abs(float(args[2]))
	selected.load_texture()
	selected.type = args[1]
	selected.value = float(args[2])
	selected.load_texture()

func print_error(message: String) -> void:
	$ui/cline/console.show()
	$ui/cline/console.text = message
	$ui/cline/console/hide_timer.start()

# ============================================================
# TIMERS & UPDATES
# ============================================================
func _on_update_timer_timeout() -> void:
	selection_material.uv1_offset += Vector3(0.025, 0.025, 0)

func _on_hide_timer_timeout() -> void:
	$ui/cline/console.hide()


func _on_map_settings_pressed() -> void:
	$ui/map_settings.visible = !$ui/map_settings.visible
