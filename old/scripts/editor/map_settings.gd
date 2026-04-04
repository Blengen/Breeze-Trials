extends Control

var settings: Node = self

func _ready() -> void:
	
	await get_tree().process_frame 
	while not settings.is_in_group("root"): settings = settings.get_parent()
	settings = settings.settings
	

func _on_name_text_submitted(new_text: String) -> void:
	settings.map_name = new_text
	update()


func _on_difficulty_text_submitted(new_text: String) -> void:
	if new_text.is_valid_float(): settings.difficulty = new_text
	update()

func _on_fuel_text_submitted(new_text: String) -> void:
	if new_text.is_valid_float(): settings.difficulty = new_text
	update()

func _on_speed_text_submitted(new_text: String) -> void:
	if new_text.is_valid_float(): settings.difficulty = new_text
	update()

func _on_jump_text_submitted(new_text: String) -> void:
	if new_text.is_valid_float(): settings.difficulty = new_text
	update()

func _on_gravity_text_submitted(new_text: String) -> void:
	if new_text.is_valid_float(): settings.difficulty = new_text
	update()

func _on_music_text_submitted(new_text: String) -> void:
	settings.music_name = new_text
	update()

func _on_file_text_submitted(new_text: String) -> void:
	settings.music_file = new_text
	update()

func _on_composer_text_submitted(new_text: String) -> void:
	settings.composer = new_text
	update()

func _on_license_text_submitted(new_text: String) -> void:
	settings.license = new_text
	update()

func _on_volume_text_submitted(new_text: String) -> void:
	if new_text.is_valid_float(): settings.music_volume = new_text
	update()

func update() -> void:
	if settings == self: return
	$scroll/vbox/name/value.text = settings.map_name
	$scroll/vbox/difficulty/value.text = str(settings.difficulty)
	$scroll/vbox/fuel/value.text = str(settings.fuel)
	$scroll/vbox/speed/value.text = str(settings.speed)
	$scroll/vbox/jump/value.text = str(settings.jump)
	$scroll/vbox/gravity/value.text = str(settings.gravity)
	$scroll/vbox/music/value.text = settings.music_name
	$scroll/vbox/file/value.text = settings.music_file
	$scroll/vbox/volume/value.text = str(settings.music_volume)
	$scroll/vbox/composer/value.text = settings.composer
	$scroll/vbox/license/value.text = settings.license


func _on_visibility_changed() -> void: update()
