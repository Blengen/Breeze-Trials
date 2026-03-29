extends Control

# This script is going to be so unreasonably long lmao

@onready var root: Node3D = $"../.."
var enabled: bool = false

@onready var vbox: VBoxContainer = $scroll/vbox

@onready var _pos: HBoxContainer = $scroll/vbox/pos
@onready var _pos1: LineEdit = $scroll/vbox/pos/value
@onready var _pos2: LineEdit = $scroll/vbox/pos/value2
@onready var _pos3: LineEdit = $scroll/vbox/pos/value3

@onready var _rot: HBoxContainer = $scroll/vbox/rot
@onready var _rot1: LineEdit = $scroll/vbox/rot/value
@onready var _rot2: LineEdit = $scroll/vbox/rot/value2
@onready var _rot3: LineEdit = $scroll/vbox/rot/value3

@onready var _size: HBoxContainer = $scroll/vbox/size
@onready var _size1: LineEdit = $scroll/vbox/size/value
@onready var _size2: LineEdit = $scroll/vbox/size/value2
@onready var _size3: LineEdit = $scroll/vbox/size/value3

@onready var _scale: HBoxContainer = $scroll/vbox/scale
@onready var _scale1: LineEdit = $scroll/vbox/scale/value
@onready var _scale2: LineEdit = $scroll/vbox/scale/value2
@onready var _scale3: LineEdit = $scroll/vbox/scale/value3

@onready var _collidable: HBoxContainer = $scroll/vbox/collidable
@onready var _collidable1: CheckBox = $scroll/vbox/collidable/check

@onready var _material: HBoxContainer = $scroll/vbox/material
@onready var _material1: OptionButton = $scroll/vbox/material/dropdown

@onready var _orb_type: HBoxContainer = $scroll/vbox/orb_type
@onready var _orb_type1: OptionButton = $scroll/vbox/orb_type/dropdown

@onready var _orb_value: HBoxContainer = $scroll/vbox/orb_value
@onready var _orb_value1: LineEdit = $scroll/vbox/orb_value/value

@onready var _radius: HBoxContainer = $scroll/vbox/radius
@onready var _radius1: LineEdit = $scroll/vbox/radius/value



# Magic numbers time :))
# Position, Rotation, Size, Scale, Collidable, Material, Orb Type, Orb Value, Radius
var prop_csgbox: Array[bool] = [true, true, true, true, true, true, false, false, false]
var prop_orb: Array[bool] = [false, false, false, true, false, false, true, true, false]
var prop_csgcylinder: Array[bool] = [true, true, false, true, true, true, false, false, false]



func _on_update_timer_timeout() -> void: # Runs 20x per second

	if !root.selected or !enabled:
		hide()
		return
	
	if !visible: show()
	show_correct_properties()

func show_correct_properties() -> void:
	
	var use: Array[bool] = []
	
	if root.selected is CSGBox3D: use = prop_csgbox
	elif root.selected.is_in_group("orb"): use = prop_orb
	elif root.selected is CSGCylinder3D: use = prop_csgcylinder
	else:
		vbox.hide()
		return
		
	vbox.show()
	
	_pos.visible = use[0]
	_rot.visible = use[1]
	_size.visible = use[2]
	_scale.visible = use[3]
	_collidable.visible = use[4]
	_material.visible = use[5]
	_orb_type.visible = use[6]
	_orb_value.visible = use[7]
	_radius.visible = use[8]
	
	# SHOW VALUES # (might lag)

	if _pos.visible:
		var __pos: Vector3 = root.selected.position
		if not _pos1.has_focus(): _pos1.text = str(__pos.x)
		if not _pos2.has_focus(): _pos2.text = str(__pos.y)
		if not _pos3.has_focus(): _pos3.text = str(__pos.z)
	if _rot.visible:
		var __rot: Vector3 = root.selected.rotation_degrees
		if not _rot1.has_focus(): _rot1.text = str(__rot.x)
		if not _rot2.has_focus(): _rot2.text = str(__rot.y)
		if not _rot3.has_focus(): _rot3.text = str(__rot.z)
	if _size.visible:
		var __size: Vector3 = root.selected.size
		if not _size1.has_focus(): _size1.text = str(__size.x)
		if not _size2.has_focus(): _size2.text = str(__size.y)
		if not _size3.has_focus(): _size3.text = str(__size.z)
	if _scale.visible:
		var __scale: Vector3 = root.selected.scale
		if not _scale1.has_focus(): _scale1.text = str(__scale.x)
		if not _scale2.has_focus(): _scale2.text = str(__scale.y)
		if not _scale3.has_focus(): _scale3.text = str(__scale.z)
		
	if _collidable.visible: _collidable1.button_pressed = root.selected.collision_layer & 1 != 0
	if _material.visible: if not _material1.has_focus(): _material1.text = (str(root.selected.material_override).trim_prefix("(res://materials/")).trim_prefix("colors/").split(".")[0]
	if _orb_type.visible: if not _orb_type1.has_focus(): _orb_type1.text = root.selected.type
	if _orb_value.visible: if not _orb_value1.has_focus(): _orb_value1.text = str(root.selected.value)
	if _radius.visible: if not _radius1.has_focus(): _radius1.text = root.selected.radius
	
func _on_properties_pressed() -> void:
	enabled = !enabled

# This gonna be long

func new_text_value(input: Variant, value: Variant) -> void:
	input.text = ""
	input.insert_text_at_caret(str(snapped(value, 0.001)))


func _on_pos1_text_submitted(new_text: String) -> void:
	if new_text.is_valid_float(): root.selected.position.x = float(new_text)
	new_text_value(_pos1, root.selected.position.x)
func _on_pos2_text_submitted(new_text: String) -> void:
	if new_text.is_valid_float(): root.selected.position.y = float(new_text)
	new_text_value(_pos2, root.selected.position.y)
func _on_pos3_text_submitted(new_text: String) -> void:
	if new_text.is_valid_float(): root.selected.position.z = float(new_text)
	new_text_value(_pos3, root.selected.position.z)


func _on_rot1_text_submitted(new_text: String) -> void:
	if new_text.is_valid_float(): root.selected.rotation_degrees.x = float(new_text)
	new_text_value(_rot1, root.selected.rotation_degrees.x)

func _on_rot2_text_submitted(new_text: String) -> void:
	if new_text.is_valid_float(): root.selected.rotation_degrees.y = float(new_text)
	new_text_value(_rot2, root.selected.rotation_degrees.y)
	
func _on_rot3_text_submitted(new_text: String) -> void:
	if new_text.is_valid_float(): root.selected.rotation_degrees.z = float(new_text)
	new_text_value(_rot3, root.selected.rotation_degrees.z)

func _on_size1_text_submitted(new_text: String) -> void:
	if new_text.is_valid_float(): root.selected.size.x = float(new_text)
	new_text_value(_size1, root.selected.size.x)


func _on_size2_text_submitted(new_text: String) -> void:
	if new_text.is_valid_float(): root.selected.size.y = float(new_text)
	new_text_value(_size2, root.selected.size.y)


func _on_size3_text_submitted(new_text: String) -> void:
	if new_text.is_valid_float(): root.selected.size.z = float(new_text)
	new_text_value(_size3, root.selected.size.z)


func _on_radius1_text_submitted(new_text: String) -> void:
	if new_text.is_valid_float(): root.selected.radius = float(new_text)
	new_text_value(_size1, root.selected.radius)


func _on_scale1_text_submitted(new_text: String) -> void:
	if new_text.is_valid_float(): root.selected.scale.x = float(new_text)
	new_text_value(_scale1, root.selected.scale.x)


func _on_scale2_text_submitted(new_text: String) -> void:
	if new_text.is_valid_float(): root.selected.scale.y = float(new_text)
	new_text_value(_scale2, root.selected.scale.y)


func _on_scale3_text_submitted(new_text: String) -> void:
	if new_text.is_valid_float(): root.selected.scale.z = float(new_text)
	new_text_value(_scale3, root.selected.scale.z)


func _on_collidable_check_toggled() -> void:
	root.selected.collision_layer ^= 1
	var collidable: bool = root.selected.collision_layer & 1 == 0
	_collidable1.button_pressed = collidable
	_collidable1.release_focus()

func set_mat(mat: String) -> void:
	var loaded_mat: StandardMaterial3D = load(mat)
	root.selected.material_override = loaded_mat

func _on_material_dropdown_item_selected(index: int) -> void:
	_material1.release_focus()
	# This is also gonna be long as hell, and have a huge blast radius, but IDK how else to do it. Maybe possible to find the text of the index.
	match index:
		1: set_mat("res://materials/textures/grass.tres")
		2: set_mat("res://materials/textures/dirt.tres")
		3: set_mat("res://materials/textures/ground.tres")
		4: set_mat("res://materials/textures/sand.tres")
		5: set_mat("res://materials/textures/brick.tres")
		6: set_mat("res://materials/textures/stone_brick.tres")
		7: set_mat("res://materials/textures/wood_rough.tres")
		8: set_mat("res://materials/textures/metal_plate.tres")
		9: set_mat("res://materials/textures/cobble.tres")
		
		11: set_mat("res://materials/colors/pale/pale_red.tres")
		12: set_mat("res://materials/colors/pale/pale_flame.tres")
		13: set_mat("res://materials/colors/pale/pale_orange.tres")
		14: set_mat("res://materials/colors/pale/pale_yellow.tres")
		15: set_mat("res://materials/colors/pale/pale_lime.tres")
		16: set_mat("res://materials/colors/pale/pale_green.tres")
		17: set_mat("res://materials/colors/pale/pale_l_blue.tres")
		18: set_mat("res://materials/colors/pale/pale_blue.tres")
		19: set_mat("res://materials/colors/pale/pale_purple.tres")
		20: set_mat("res://materials/colors/pale/pale_pink.tres")
		
		22: set_mat("res://materials/colors/standard/red.tres")
		23: set_mat("res://materials/colors/standard/flame.tres")
		24: set_mat("res://materials/colors/standard/orange.tres")
		25: set_mat("res://materials/colors/standard/yellow.tres")
		26: set_mat("res://materials/colors/standard/lime.tres")
		27: set_mat("res://materials/colors/standard/green.tres")
		28: set_mat("res://materials/colors/standard/l_blue.tres")
		29: set_mat("res://materials/colors/standard/blue.tres")
		30: set_mat("res://materials/colors/standard/purple.tres")
		31: set_mat("res://materials/colors/standard/pink.tres")

		33: set_mat("res://materials/colors/dark/dark_red.tres")
		34: set_mat("res://materials/colors/dark/dark_flame.tres")
		35: set_mat("res://materials/colors/dark/dark_orange.tres")
		36: set_mat("res://materials/colors/dark/dark_yellow.tres")
		37: set_mat("res://materials/colors/dark/dark_lime.tres")
		38: set_mat("res://materials/colors/dark/dark_green.tres")
		39: set_mat("res://materials/colors/dark/dark_l_blue.tres")
		40: set_mat("res://materials/colors/dark/dark_blue.tres")
		41: set_mat("res://materials/colors/dark/dark_purple.tres")
		42: set_mat("res://materials/colors/dark/dark_pink.tres")

		44: set_mat("res://materials/other/white.tres")
		45: set_mat("res://materials/other/l_gray.tres")
		46: set_mat("res://materials/other/gray.tres")
		47: set_mat("res://materials/other/d_gray.tres")
		48: set_mat("res://materials/other/black.tres")
		
		49: set_mat("res://materials/other/hidden.tres")
