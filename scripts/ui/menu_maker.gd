extends Control

# Assets
@onready var label: PackedScene = preload("res://scenes/ui/elements/labels/menu_maker_label.tscn")
@onready var button: PackedScene = preload("res://scenes/ui/elements/buttons/menu_maker_button.tscn")

# Children
@onready var vbox: VBoxContainer = $vbox
@onready var logic_handler: Node = $logic_handler


func text_settings(object: Node, args: PackedStringArray) -> void: # Sets color, font size, text, and outline thickness
	# Set font size, color, and text, based on argument 2, 3, and 4
	object["theme_override_font_sizes/font_size"] = args[1].to_int() # Font size

	var color_values: Array[Variant] = args[2].split(",") # Color, based on 3 numbers divided by ","
	object["theme_override_colors/font_color"] = Color(
		color_values[0].to_float(),
		color_values[1].to_float(),
		color_values[2].to_float(), 1)

	object.text = args[3] # Displayed Text

	# Set it's outline size to 1/10 of the text size
	object["theme_override_constants/outline_size"] = int(((args[1].to_float()) / 10))
	pass

func button_press(id: String) -> void: # On button pressed
	if id == "useless": get_tree().quit()

func _ready() -> void: # Make the menu
	
	var text: PackedStringArray = $string.text.split("
", false) # Array of each line in the string
	if !text: return # Failsafe
	
	for line: String in text: # Cycle through each element in the string
		
		var args: PackedStringArray = line.split("§") # Get arguments for this line
		
		if args[0] == "label":
			var new_label: Label = label.instantiate()
			vbox.add_child(new_label) # Add new basic label
			text_settings(new_label, args) # Sets color, font size, text, and outline thickness
			
		elif args[0] == "button":
			var new_button: Button = button.instantiate()
			vbox.add_child(new_button) # Add new basic button
			new_button.id = args[3]
			text_settings(new_button, args) # Sets color, font size, text, and outline thickness
