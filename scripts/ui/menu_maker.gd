extends Control

#region Definitions
# Assets
@onready var label: PackedScene = preload("res://scenes/ui/elements/labels/menu_maker_label.tscn")
@onready var button: PackedScene = preload("res://scenes/ui/elements/buttons/menu_maker_button.tscn")

# Children
@onready var vbox: VBoxContainer = $scroll/vbox
@onready var scroll: ScrollContainer = $scroll
@onready var logic_handler: Node = $logic_handler
#endregion Definitions

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
	logic_handler.button_press(id)
	

func _ready() -> void: # Make the menu
	
	scroll.set_deferred("size", Vector2(1920, 1080)) # Reset ScrollContainer so the VBox can scale properly
	await get_tree().process_frame
	
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
			new_button.id = args[4]
			text_settings(new_button, args) # Sets color, font size, text, and outline thickness
	
	await get_tree().process_frame
	
	scroll.set_deferred("size", vbox.size)
	if vbox.size.y > 1080: scroll.set_deferred("size", Vector2(vbox.size.x, 1080))
	scroll.position.x = (1920 - vbox.size.x) / 2
	scroll.position.y = (1080 - vbox.size.y) / 2
	if scroll.position.y < 0: scroll.position.y = 0
		
func erase() -> void:
	for child in vbox.get_children(): child.queue_free()
