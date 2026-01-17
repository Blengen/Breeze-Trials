extends Node


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("esc"):
		if !get_tree().paused: pause()
		else: unpause()


func _on_continue_pressed() -> void: unpause()

func pause():
	$"../pause_menu".show()
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
func unpause():
	$"../pause_menu".hide()
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _on_exit_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/menu/main_menu.tscn")
