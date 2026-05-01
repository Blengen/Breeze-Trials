extends Node

@onready var menu_maker: Control = $".."
@onready var string: Label = $"../string"

func button_press(id: String) -> void:
	
	if id == "continue":
		$"../..".hide()
		get_tree().paused = false
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	if id == "settings":
		$"../../settings".show()
		$"../../settings/menu_maker/logic_handler".update_button_values()

	if id == "exit":
		get_tree().set_deferred("paused", false)
		get_tree().change_scene_to_file("res://scenes/ui/menus_full/main_menu.tscn")
