extends Node3D

# This was messy as hell so I got DeepSeek to refactor it ... does anyone actually look at the source code?
# Slightly buggy, some command extensions don't work.

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
var save_scene: Variant = null
var playing: bool = true
var hihat_juice: float = -1
var hihat_count: int = -1

# Transform mode
var transform_mode: String = "move"          # "move", "size", "rotate"
var transform_dir: String = "x"              # "x", "y", "z"
var transforming: bool = false
var transform_x: float = 0
var transform_y: float = 0
var origin: Vector3 = Vector3.ZERO
var increment: Vector3 = Vector3(1, 1, 1)
var rotation_increment: float = 22.5
var transform_object: Node = null

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
	add_child(load(global.temp_file).instantiate())
	DirAccess.rename_absolute(global.temp_file, global.selected_map)
	DirAccess.remove_absolute(global.temp_file)
	
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
	
	# Cube Settings
	cube_instance.position = player.position + Vector3(0, -1, -5)
	cube_instance.position = snapped(cube_instance.position, Vector3(1, 1, 1))
	cube_instance.size = Vector3(3, 3, 3)
	cube_instance.use_collision = true
	cube_instance.collision_layer = 1 | 3
	
	# Add Cube
	main.add_child(cube_instance)
	cube_instance.owner = map

func _on_lock_cursor_pressed() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	$"ui/top_bar/items_middle/1".text = "ESC to return"
	if selected:
		selected.material_overlay = null
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
	if err == OK: $save_dialog.show()
	else: print_error("Something went wrong under saving " + str(err))
	$"ui/top_bar/items_right/4".disabled = false
	$"ui/top_bar/items_right/4/disable_timer".start()

func _on_save_pressed() -> void:
	pass # Not implemented yet

func _on_file_dialog_file_selected(path: String) -> void:
	
	path = path.trim_suffix("btmap")

	if path.ends_with(".btmap"): path.trim_suffix(".btmap")
	if not path.ends_with(".tscn"): path += ".tscn"
	
	var err: Error = ResourceSaver.save(save_scene, path)
	
	if err != OK: print_error("Map did not save properly: " + str(err))
	else: DirAccess.rename_absolute(path, path.trim_suffix("tscn") + "btmap")

func _on_disable_timer_timeout() -> void: $"ui/top_bar/items_right/3".disabled = true

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
	selected = null

	if object:
		selected = object
		if object is CSGShape3D:
			object.material_overlay = selection_material
		elif selected is Area3D and selected.is_in_group("orb"):
			selected.sprite.modulate = Color(0.5, 0.5, 0.5)

# ============================================================
# INPUT & TRANSFORM HANDLING
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
			origin = transform_object.size
		"rotate":
			origin = transform_object.rotation_degrees

func update_transform() -> void:
	# Determine increment
	if Input.is_action_pressed("increment_small"):
		increment = Vector3(0.25, 0.25, 0.25)
	elif Input.is_action_pressed("increment_smaller"):
		increment = Vector3(0.05, 0.05, 0.05)
	else:
		increment = Vector3(1, 1, 1)

	match transform_dir:
		"x":
			if transform_mode == "move":
				transform_object.position = origin + snapped(Vector3(transform_x * 0.05, 0, transform_y * 0.05), increment)
			elif transform_mode == "size" and transform_object is CSGShape3D:
				transform_object.size = origin + snapped(Vector3(transform_x * 0.05, 0, transform_y * 0.05), increment)
				# Keep minimum size
				if transform_object.size.x < increment.x:
					transform_object.size.x = increment.x
				if transform_object.size.z < increment.z:
					transform_object.size.z = increment.z
			elif transform_mode == "rotate":
				transform_object.rotation_degrees.x = origin.x - snappedf(transform_y, rotation_increment)

		"y":
			if transform_mode == "move":
				transform_object.position.y = origin.y + snappedf(-transform_y * 0.05, increment.x)
			elif transform_mode == "size" and transform_object is CSGShape3D:
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

	# Dispatch commands
	match command:
		# Transform commands
		"size", "size+", "sizex", "sizex+", "sizey", "sizey+", "sizez", "sizez+": handle_transform_command(command, rest)
		"pos", "pos+", "posx", "posx+", "posy", "posy+", "posz", "posz+": handle_transform_command(command, rest)
		"rot", "rot+", "rotx", "rotx+", "roty", "roty+", "rotz", "rotz+": handle_transform_command(command, rest)
			

		# Other commands
		"mat":
			handle_material_command(rest)
		"col":
			handle_collision_command(rest)
		"matlist":
			print_material_list()
		"help":
			print_help()
		"dupe":
			handle_duplicate()
		"del":
			handle_delete()
		_:
			print_error("Unknown command: " + command)

func handle_transform_command(cmd: String, args: Array) -> void:
	if not selected:
		print_error("No object selected")
		return

	# Parse the command components
	var base: String
	var axis: String
	var operator: String

	# Split the command into base (size/pos/rot) and optional axis/operator
	# Examples: size, size+, sizex, sizex+, sizey, sizey+, etc.
	if cmd.begins_with("size"):
		base = "size"
		var suffix: String = cmd.trim_prefix("size")
		parse_suffix(suffix, axis, operator)
	elif cmd.begins_with("pos"):
		base = "pos"
		var suffix: String = cmd.trim_prefix("pos")
		parse_suffix(suffix, axis, operator)
	elif cmd.begins_with("rot"):
		base = "rot"
		var suffix: String = cmd.trim_prefix("rot")
		parse_suffix(suffix, axis, operator)
	else:
		return # Should not happen

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
	var expected_args: int
	if axis == "":
		expected_args = 3
	else:
		expected_args = 1

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
		# All axes
		var new_vec: Vector3
		if operator == "+":
			new_vec = prop + Vector3(values[0], values[1], values[2])
		else:
			new_vec = Vector3(values[0], values[1], values[2])
		apply_transform(base, new_vec)
	else:
		# Single axis
		var idx: int = 0
		match axis:
			"x": idx = 0
			"y": idx = 1
			"z": idx = 2
		var delta: float = values[0]
		var new_val: float
		if operator == "+":
			new_val = prop[idx] + delta
		else:
			new_val = delta

		var new_vec: Vector3 = prop
		new_vec[idx] = new_val
		apply_transform(base, new_vec)

func parse_suffix(suffix: String, axis: String, operator: String) -> void:
	# suffix examples: "", "+", "x", "x+", "y", "y+", "z", "z+"
	
	# Some weirdass shenanigans because otherwise Godot screams at me for unused variables ... even though they are used.
	@warning_ignore("standalone_expression")
	axis + operator
	
	if suffix.is_empty():
		axis = ""
		operator = ""
	elif suffix == "+":
		axis = ""
		operator = "+"
	elif suffix == "x":
		axis = "x"
		operator = ""
	elif suffix == "x+":
		axis = "x"
		operator = "+"
	elif suffix == "y":
		axis = "y"
		operator = ""
	elif suffix == "y+":
		axis = "y"
		operator = "+"
	elif suffix == "z":
		axis = "z"
		operator = ""
	elif suffix == "z+":
		axis = "z"
		operator = "+"
	else:
		# Unknown suffix, treat as no axis/operator? We'll just set defaults
		axis = ""
		operator = ""

func apply_transform(base: String, new_val: Vector3) -> void:
	match base:
		"size":
			selected.size = new_val
			# Ensure positive size (optional)
			if selected.size.x < 0.1:
				selected.size.x = 0.1
			if selected.size.y < 0.1:
				selected.size.y = 0.1
			if selected.size.z < 0.1:
				selected.size.z = 0.1
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
		# Toggle
		if selected.collision_layer == 4:
			selected.collision_layer = 5
		else:
			selected.collision_layer = 4
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
	selected.material_overlay = null
	selected = duplicated

func handle_delete() -> void:
	if not selected:
		print_error("No object selected")
		return
	selected.queue_free()
	selected = null

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
