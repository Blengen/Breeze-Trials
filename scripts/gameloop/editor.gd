extends Node3D

@onready var player: CharacterBody3D
@onready var map: Node3D
@onready var main: Node3D
@onready var spawn: Node3D
@onready var settings: Node
@onready var ani: AnimationPlayer # Player AnimationPlayer

@onready var cline: LineEdit = $ui/cline

var selected: Node
var save_scene: Variant = null


var playing: bool = true
var hihat_juice: float = -1 # Acts like a timer for hihats. When it crosses a threshold, the audio plays.
var hihat_count: int = -1

var selection_material: StandardMaterial3D = preload("res://materials/selection.tres")

var transform_mode: String = "move"
var transform_dir: String = "x"
var transforming: bool = false
var transform_x: float = 0
var transform_y: float = 0
var origin: Vector3 = Vector3.ZERO
var increment: Vector3 = Vector3(1, 1, 1)
var rotation_increment: float = 22.5
var transform_object: Node = null

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

func fix_variables() -> void:
	player = $player/body
	map = $map
	main = $map/main
	spawn = $map/spawn
	settings = $map/settings
	ani = $player/body/visual/ani # Player AnimationPlayer

func _ready() -> void:
	add_child(load(global.selected_map).instantiate())
	fix_variables()
	player.position = spawn.position

# BUTTONS

func _on_add_cube_pressed() -> void:
	var cube_instance: CSGBox3D = CSGBox3D.new()
	cube_instance.position = player.position + Vector3(0, -1, -5)
	cube_instance.position = snapped(cube_instance.position, Vector3(1, 1, 1))
	cube_instance.size = Vector3(3, 3, 3)
	cube_instance.use_collision = true
	cube_instance.collision_layer = 1 | 3
	main.add_child(cube_instance)
	
	cube_instance.owner = map
	
func _on_lock_cursor_pressed() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	$"ui/top_bar/items_middle/1".text = "ESC to return"
	if selected: selected.material_overlay = null
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


func _on_exit_pressed() -> void: get_tree().change_scene_to_file("res://scenes/menu/main_menu.tscn")

func _unhandled_input(event: InputEvent) -> void:
	
	if event is InputEventMouseMotion and transforming and transform_object:
		transform_x += event.relative.x
		transform_y += event.relative.y
		
		if Input.is_action_pressed("increment_small"): increment = Vector3(0.25, 0.25, 0.25)
		elif Input.is_action_pressed("increment_smaller"): increment = Vector3(0.05, 0.05, 0.05)
		else: increment = Vector3(1, 1, 1)
		
		if transform_dir == "x":
			if transform_mode == "move": transform_object.position = origin + snapped(Vector3(transform_x * 0.05, 0, transform_y * 0.05), increment)
			elif transform_mode == "size" and transform_object is CSGShape3D:
				transform_object.size = origin + snapped(Vector3(transform_x * 0.05, 0, transform_y * 0.05), increment)
				if transform_object.size.x < increment.x: transform_object.size.x = increment.x
				if transform_object.size.z < increment.z: transform_object.size.z = increment.z
				
			elif transform_mode == "rotate": transform_object.rotation_degrees.x = origin.x - snappedf(transform_y, rotation_increment)
			
		elif transform_dir == "y":
			if transform_mode == "move": transform_object.position.y = origin.y + snappedf(-transform_y * 0.05, increment.x)
			elif transform_mode == "size" and transform_object is CSGShape3D:
				transform_object.size.y = origin.y + snappedf(-transform_y * 0.05, increment.x)
				if transform_object.size.z < increment.z: transform_object.size.z = increment.z
				
			elif transform_mode == "rotate": transform_object.rotation_degrees.y = origin.y + snappedf(transform_x, rotation_increment)
		elif transform_dir == "z" and transform_mode == "rotate": transform_object.rotation_degrees.z = origin.z + snappedf(transform_y, rotation_increment)
		
	if event is InputEventKey:
		if (selected or transform_object) and Input.is_action_just_pressed("transform_xz"): transform_settings("x")
		elif (selected or transform_object) and Input.is_action_just_pressed("transform_y"): transform_settings("y")
		elif (selected or transform_object) and Input.is_action_just_pressed("transform_z"): transform_settings("z")
		
func transform_settings(dir: String) -> void:
	if transforming:
		transforming = false
		transform_x = 0
		transform_y = 0
		transform_object = null
	else:
		transform_dir = dir
		transforming = true
		transform_object = selected
		set_origin()


func set_origin() -> void:
	if transform_mode == "move": origin = selected.position
	elif transform_mode == "size": origin = selected.size
	elif transform_mode == "rotate": origin = selected.rotation_degrees
		
func _on_update_timer_timeout() -> void:
	selection_material.uv1_offset += Vector3(0.025, 0.025, 0)

func selection(object: Node) -> void:
	
	if selected is CSGShape3D: selected.material_overlay = null
	elif selected is Area3D and selected.is_in_group("orb"): selected.sprite.modulate = Color(1, 1, 1)
	selected = null
	
	if object:
		selected = object
		if object is CSGShape3D: object.material_overlay = selection_material
		elif selected is Area3D and selected.is_in_group("orb"): selected.sprite.modulate = Color(0.5, 0.5, 0.5)
	


func _on_cline_text_submitted(cmd: String) -> void:
	cline.text = ""
	cmd = cmd.to_lower()
	var args: Array = cmd.split(" ", false)
	
	if args.size() == 0: return
	
	match args[0]:
		"size":
			# Failsafes
			if !selected: print_error("No object selected to resize")
			elif args.size() != 4: print_error("Expected 3 arguments (XYZ), got " + str(args.size() - 1) + ".")

			else: # Failsafes not triggered, correct input.
				if args[1].is_valid_float(): selected.size.x = float(args[1])
				if args[2].is_valid_float(): selected.size.y = float(args[2])
				if args[3].is_valid_float(): selected.size.z = float(args[3])

		"size+":
			# Failsafes
			if !selected: print_error("No object selected to resize")
			elif args.size() != 4: print_error("Expected 3 arguments (XYZ), got " + str(args.size() - 1) + ".")

			else: # Failsafes not triggered, correct input.
				if args[1].is_valid_float(): selected.size.x += float(args[1])
				if args[2].is_valid_float(): selected.size.y += float(args[2])
				if args[3].is_valid_float(): selected.size.z += float(args[3])

		"sizex":
			# Failsafes
			if !selected: print_error("No object selected to resize")
			elif args.size() != 2: print_error("Expected 1 argument (X), got " + str(args.size() - 1) + ".")
			else: # Failsafes not triggered, correct input.
				if args[1].is_valid_float(): selected.size.x = float(args[1])

		"sizex+":
			# Failsafes
			if !selected: print_error("No object selected to resize")
			elif args.size() != 2: print_error("Expected 1 argument (X), got " + str(args.size() - 1) + ".")
			else: # Failsafes not triggered, correct input.
				if args[1].is_valid_float(): selected.size.x += float(args[1])

		"sizey":
			# Failsafes
			if !selected: print_error("No object selected to resize")
			elif args.size() != 2: print_error("Expected 1 argument (Y), got " + str(args.size() - 1) + ".")
			else: # Failsafes not triggered, correct input.
				if args[1].is_valid_float(): selected.size.y = float(args[1])

		"sizey+":
			# Failsafes
			if !selected: print_error("No object selected to resize")
			elif args.size() != 2: print_error("Expected 1 argument (Y), got " + str(args.size() - 1) + ".")
			else: # Failsafes not triggered, correct input.
				if args[1].is_valid_float(): selected.size.y += float(args[1])

		"sizez":
			# Failsafes
			if !selected: print_error("No object selected to resize")
			elif args.size() != 2: print_error("Expected 1 argument (Z), got " + str(args.size() - 1) + ".")
			else: # Failsafes not triggered, correct input.
				if args[1].is_valid_float(): selected.size.z = float(args[1])

		"sizez+":
			# Failsafes
			if !selected: print_error("No object selected to resize")
			elif args.size() != 2: print_error("Expected 1 argument (Z), got " + str(args.size() - 1) + ".")
			else: # Failsafes not triggered, correct input.
				if args[1].is_valid_float(): selected.size.z += float(args[1])
		
		# POSITION #
		
		"pos":
			# Failsafes
			if !selected: print_error("No object selected to move")
			elif args.size() != 4: print_error("Expected 3 arguments (XYZ), got " + str(args.size() - 1) + ".")

			else: # Failsafes not triggered, correct input.
				if args[1].is_valid_float(): selected.position.x = float(args[1])
				if args[2].is_valid_float(): selected.position.y = float(args[2])
				if args[3].is_valid_float(): selected.position.z = float(args[3])

		"pos+":
			# Failsafes
			if !selected: print_error("No object selected to move")
			elif args.size() != 4: print_error("Expected 3 arguments (XYZ), got " + str(args.size() - 1) + ".")

			else: # Failsafes not triggered, correct input.
				if args[1].is_valid_float(): selected.position.x = float(args[1])
				if args[2].is_valid_float(): selected.position.y = float(args[2])
				if args[3].is_valid_float(): selected.position.z = float(args[3])

		"posx":
			# Failsafes
			if !selected: print_error("No object selected to move")
			elif args.size() != 2: print_error("Expected 1 argument (X), got " + str(args.size() - 1) + ".")
			else: # Failsafes not triggered, correct input.
				if args[1].is_valid_float(): selected.position.x = float(args[1])

		"posx+":
			# Failsafes
			if !selected: print_error("No object selected to move")
			elif args.size() != 2: print_error("Expected 1 argument (X), got " + str(args.size() - 1) + ".")
			else: # Failsafes not triggered, correct input.
				if args[1].is_valid_float(): selected.position.x += float(args[1])

		"posy":
			# Failsafes
			if !selected: print_error("No object selected to move")
			elif args.size() != 2: print_error("Expected 1 argument (Y), got " + str(args.size() - 1) + ".")
			else: # Failsafes not triggered, correct input.
				if args[1].is_valid_float(): selected.position.y = float(args[1])

		"posy+":
			# Failsafes
			if !selected: print_error("No object selected to move")
			elif args.size() != 2: print_error("Expected 1 argument (Y), got " + str(args.size() - 1) + ".")
			else: # Failsafes not triggered, correct input.
				if args[1].is_valid_float(): selected.position.y += float(args[1])

		"posz":
			# Failsafes
			if !selected: print_error("No object selected to move")
			elif args.size() != 2: print_error("Expected 1 argument (Z), got " + str(args.size() - 1) + ".")
			else: # Failsafes not triggered, correct input.
				if args[1].is_valid_float(): selected.position.z = float(args[1])

		"posz+":
			# Failsafes
			if !selected: print_error("No object selected to move")
			elif args.size() != 2: print_error("Expected 1 argument (Z), got " + str(args.size() - 1) + ".")
			else: # Failsafes not triggered, correct input.
				if args[1].is_valid_float(): selected.position.z += float(args[1])

		"rot":
			# Failsafes
			if !selected: print_error("No object selected to rotate")
			elif args.size() != 4: print_error("Expected 3 arguments (XYZ), got " + str(args.size() - 1) + ".")

			else: # Failsafes not triggered, correct input.
				if args[1].is_valid_float(): selected.rotation_degrees.x = float(args[1])
				if args[2].is_valid_float(): selected.rotation_degrees.y = float(args[2])
				if args[3].is_valid_float(): selected.rotation_degrees.z = float(args[3])

		"rot+":
			# Failsafes
			if !selected: print_error("No object selected to rotate")
			elif args.size() != 4: print_error("Expected 3 arguments (XYZ), got " + str(args.size() - 1) + ".")

			else: # Failsafes not triggered, correct input.
				if args[1].is_valid_float(): selected.rotation_degrees.x += float(args[1])
				if args[2].is_valid_float(): selected.rotation_degrees.y += float(args[2])
				if args[3].is_valid_float(): selected.rotation_degrees.z += float(args[3])

		"rotx":
			# Failsafes
			if !selected: print_error("No object selected to rotate")
			elif args.size() != 2: print_error("Expected 1 argument (X), got " + str(args.size() - 1) + ".")
			else: # Failsafes not triggered, correct input.
				if args[1].is_valid_float(): selected.rotation_degrees.x = float(args[1])

		"rotx+":
			# Failsafes
			if !selected: print_error("No object selected to rotate")
			elif args.size() != 2: print_error("Expected 1 argument (X), got " + str(args.size() - 1) + ".")
			else: # Failsafes not triggered, correct input.
				if args[1].is_valid_float(): selected.rotation_degrees.x += float(args[1])

		"roty":
			# Failsafes
			if !selected: print_error("No object selected to rotate")
			elif args.size() != 2: print_error("Expected 1 argument (Y), got " + str(args.size() - 1) + ".")
			else: # Failsafes not triggered, correct input.
				if args[1].is_valid_float(): selected.rotation_degrees.y = float(args[1])

		"roty+":
			# Failsafes
			if !selected: print_error("No object selected to rotate")
			elif args.size() != 2: print_error("Expected 1 argument (Y), got " + str(args.size() - 1) + ".")
			else: # Failsafes not triggered, correct input.
				if args[1].is_valid_float(): selected.rotation_degrees.y += float(args[1])

		"rotz":
			# Failsafes
			if !selected: print_error("No object selected to rotate")
			elif args.size() != 2: print_error("Expected 1 argument (Z), got " + str(args.size() - 1) + ".")
			else: # Failsafes not triggered, correct input.
				if args[1].is_valid_float(): selected.rotation_degrees.z = float(args[1])

		"rotz+":
			# Failsafes
			if !selected: print_error("No object selected to rotate")
			elif args.size() != 2: print_error("Expected 1 argument (Z), got " + str(args.size() - 1) + ".")
			else: # Failsafes not triggered, correct input.
				if args[1].is_valid_float(): selected.rotation_degrees.z += float(args[1])
				
		# Other commands
		
		"mat":
			# Failsafes
			if !selected: print_error("No object selected to change material")
			elif args.size() != 2: print_error("Expected 1 argument (Material Name), got " + str(args.size() - 1) + ".")
			elif not materials.has(args[1]): print_error("Invalid Material name. Use \"matlist\" to see names. Check spelling.")
			
			# Failsafes not triggered, correct input 
			else: selected.material_override = materials[args[1]] 
		
		"col":
			# Failsafes
			if !selected: print_error("No object selected to change collision")
			
			# Failsafes not triggered, correct input 
			else:
				if cmd.contains("true"): selected.collision_layer = 5
				elif cmd.contains("false"): selected.collision_layer = 4
				else:
					if selected.collision_layer == 4: selected.collision_layer = 5
					else: selected.collision_layer = 4
		
		"matlist":
			print_error("Colors: red, flame, orange, yellow, lime, green, l_blue, blue, purple, pink.
			Dark and pale variants (\"dark_red\").
			Textures: brick, stone_brick, cobble, dirt, ground, grass, metal_plate,
			metal_plate, sand, wood_rough. Other: hidden, white, l_gray, gray, d_gray, black"
			)
		
		"help":
			print_error("size, sizex, sizey, sizez, size+, sizex+ sizey+ sizez+ same structure but replace \"size\"
			with \"pos\" (position) or \"rot\" (rotation) col, col true, col false (collision), mat (material name)
			matlist (see material names) This is extremely confusing so I recommend watching the tutorial.")
			
		
func _on_hide_timer_timeout() -> void: $ui/cline/console.hide()
	
func print_error(message: String) -> void:
	$ui/cline/console.show()
	$ui/cline/console.text = message
	$ui/cline/console/hide_timer.start()
	
func _on_save_pressed() -> void:
	save_scene = PackedScene.new()
	var err: Error = save_scene.pack($map)
	if err == OK: $FileDialog.show()
	$"ui/top_bar/items_right/3".disabled = false
	$"ui/top_bar/items_right/3/disable_timer".start()
	
func _on_file_dialog_file_selected(path: String) -> void: ResourceSaver.save(save_scene, path)
func _on_disable_timer_timeout() -> void: $"ui/top_bar/items_right/3".disabled = true
