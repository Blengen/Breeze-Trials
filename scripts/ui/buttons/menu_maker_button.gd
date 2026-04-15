extends Button

@onready var menu_maker: Node = self
var id: String = ""

func _ready() -> void: # Identify Menu Maker and run animation. Probably unecessarily safe
	
	for count in range(100): # Max 100 iterations to be safe
		
		if menu_maker == null:
			print("Something went wrong, parent = null")
			return
		
		if not menu_maker.is_in_group("menu_maker"): menu_maker = menu_maker.get_parent()
		else: return
		
	# If loops run without finding
	print("Something went wrong, couldn't find menu_maker parent")

func _on_pressed() -> void:
	if menu_maker.is_in_group("menu_maker"): menu_maker.button_press(id)


func _on_mouse_entered() -> void:
	pass # Replace with function body.
