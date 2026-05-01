extends Node

@onready var menu_maker: Control = $".."
@onready var string: Label = $"../string"

func _ready() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	$"../settings".hide()

func button_press(id: String) -> void:
	
	if id == "back":
		menu_maker.erase()
		string.text = "
label§200§0,1,0.7§Breeze Trials
label§60§0,1,0§v0.1 WIP
button§100§1,1,1§Main Maps§main
button§100§1,1,1§Custom Maps§custom
button§100§1,1,1§Settings§settings
button§100§1,1,1§Credits§credits

label§50§1,1,1§ 
button§100§1,1,1§Exit§exit
"
		menu_maker._ready()
		
	if id == "main":
		menu_maker.erase()
		string.text = "
label§200§1,1,0.3§Main Maps
button§100§1,1,1§Sandbox§sandbox
label§50§1,1,1§ 
button§100§1,1,1§Map Template§1
button§100§1,1,1§Map Template§2
label§50§1,1,1§ 
button§100§1,1,1§Back§back
"
		menu_maker._ready()

	if id == "custom":
		menu_maker.erase()
		string.text = "
label§200§1,0,0.7§Custom Maps
button§100§1,1,1§Play Map§play
button§100§1,1,1§Edit Map§edit
button§100§1,1,1§New Map§new

label§50§1,1,1§ 
button§100§1,1,1§Back§back
"
		menu_maker._ready()

	if id == "settings":
		$"../settings".show()

	if id == "credits":
		menu_maker.erase()
		string.text = "
label§200§0,0.5,1§Credits
label§100§1,1,1§Cool thing
label§50§1,1,1§This person helped

label§50§1,1,1§ 
button§100§1,1,1§Back§back
"
		menu_maker._ready()

	if id == "exit": get_tree().quit()
	if id == "sandbox":
		global.selected_map = "res://-MAPS/sandbox.btmap.tscn"
		get_tree().change_scene_to_file("res://scenes/play/play.tscn")
		
		pass
	
