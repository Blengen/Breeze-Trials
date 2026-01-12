extends CharacterBody3D

# Variables
#region variables

# Nodes
@onready var rig = $"../cam_rig"
@onready var cam = $"../cam_rig/cam"
@onready var ani = $visual/ani
@onready var camlock_ui = $"../ui/camlock"
@onready var visual = $visual
@onready var root = $"../.."
@onready var fuel_label = $"../ui/fuel"

# From Global
var sensitivity: float = global.sens

# Player Stats
var speed: float = 20
var jump_power: float = 60
var grav: float = 250
const coyotetime: float = 0.1
const air_control: float = 0.4
#const deceleration: int = 500
const air_multiplier = 0.99

# Player state variables
var input_vector: Vector2 = Vector2.ZERO
var airtime: float = 0
var coyote: float = 0
var jump_check: bool = false
var tsla: float = 1 # Time Since Last Ability
var fuel: float = 1
var restart_juice: float = 0
var ability_buffered: bool = false
var ability_buffer_active: bool = false

var ability_list: Array = []
var delta_slow: float = 0

# Camera variables
var cam_mode: String = "none"
var zoom: float = 12.5

# Smooth Rotation
const rotation_speed = 15
const rotation_threshold = 0.1  # Snap when within 0.1 degrees
var target_angle = 0.0
var offset = 0 # Offset when holding WASD

# DEBUG #

var fps_list = []
var fps_average: float = 0



#endregion

# Setup, callables, and other functions
#region callables

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if cam_mode == "none": return
		rig.rotation_degrees.y -= event.relative.x * sensitivity
		rig.rotation_degrees.x -= event.relative.y * sensitivity
		rig.rotation_degrees.x = clamp(rig.rotation_degrees.x, -90, 90)
	

func get_input_vector():
	input_vector = Input.get_vector("left", "right", "front", "back")
	return input_vector
	
func get_rig_basis():
	var old_rotation_x = rig.rotation_degrees.x
	rig.rotation_degrees.x = 0
	var rig_basis = rig.transform.basis
	rig.rotation_degrees.x = old_rotation_x
	return rig_basis

func vector2_to_deg(value):
	match value:
		Vector2(0, 1): return 180
		Vector2(1, 0): return 270
		#Vector2(0, -1): return 0
		Vector2(-1, 0): return 90
		
	if value == Vector2(1, 1).normalized(): return 235
	elif value == Vector2(-1, 1).normalized(): return 135
	elif value == Vector2(-1, -1).normalized(): return 45
	elif value == Vector2(1, -1).normalized(): return 315
		
	return 0

func find_shortest_turn():
	while target_angle > 360: target_angle -= 360
	while target_angle < 0: target_angle += 360
	
	target_angle += 360
	var best_angle = 99999
	for count in range(4):
		if abs(target_angle - rotation_degrees.y) < abs(best_angle - rotation_degrees.y): best_angle = target_angle
		target_angle -= 360
	target_angle = best_angle

func death(type):
	$"../ui/death_ui".visible = true
	root.playing = false
	$"../ui/death_ui/cover".color = Color(1.0, 1.0, 1.0, 0.75)
	$"../cam_rig/cam/shake".shake_node = true
	ani.stop()
	$"../../sfx/death".play()
	$"../../map/settings/song".stop()
	$"../ui/vignette_fuel".modulate.a = 0
	if type is float: $"../ui/death_ui/reason".text = "Late by " + str(abs(snappedf(fuel, 0.001))) + "s"
	else:
		if type == "fuel": $"../ui/death_ui/reason".text = "Ran out of fuel"
		elif type == "win": $"../ui/death_ui/reason".text = "GG! " + str(abs(snappedf(fuel, 0.001))) + "s left"
	



#endregion

# Function Groups & Process
#region groups
func _process(delta: float) -> void: # Runs every frame
	
	# Runs all the time
	camera()
	handle_restart(delta)
	debug(delta)
	
	if root.playing: # Only runs after spawn
		get_input_vector()
		player_rotation(delta)
		animation()
		handle_fuel(delta)
		do_ability()
		movement(delta)
		move_and_slide()
	
	# Runs all the time. After ingame ones #
	set_variables(delta)
	
func vertical_movement(delta: float) -> void:
	gravity(delta)
	jump(delta)
	quick_drop()
	
func movement(delta: float) -> void:
	get_input_vector()
	move(delta) # WASD movement
	vertical_movement(delta)
	
#endregion

# Functions
#region functions
func move(delta: float):
	
	var normalized_input_vector = input_vector.normalized() # Corrects speed if you go diagonally
	var current_speed = Vector2(velocity.x, velocity.z).length()
	
	
	#if current_speed >= speed + 0.05:
	velocity += get_rig_basis() * Vector3(normalized_input_vector.x * air_control * delta, 0, normalized_input_vector.y * air_control * delta)
		
	# Old decelleration code
	delta_slow += delta * 1000 # Checks how much time has passed to determine how many slow passes to do.
	var floored_delta_slow: float = floor(delta_slow)
	velocity.x *= air_multiplier**floored_delta_slow
	velocity.z *= air_multiplier**floored_delta_slow
	delta_slow -= floored_delta_slow
	
	# New Move-toward code suggested by AI (DeepSeek)
	
	#var vel = Vector2(velocity.x, velocity.z)
	#vel = vel.move_toward(Vector2.ZERO, delta * deceleration)
	#velocity.x = vel.x
	#velocity.z = vel.y
		
	if not current_speed >= speed + 0.25:
		velocity = get_rig_basis() * Vector3(normalized_input_vector.x * speed, velocity.y, normalized_input_vector.y * speed)
		delta_slow = 0
	
	#velocity = get_rig_basis() * Vector3(normalized_input_vector.x * speed, velocity.y, normalized_input_vector.y * speed) # Temp fix

func jump(delta):
	if is_on_floor():
		coyote = 0
		if Input.is_action_pressed("jump"):
			velocity.y = jump_power
			ani.play("jump")
			jump_check = true
			coyote = 1
	
	else:
		coyote += delta
		if coyote < coyotetime and Input.is_action_pressed("jump"):
			velocity.y = jump_power
			ani.play("jump")
			jump_check = true
			coyote = 1
	

func gravity(delta):
	if is_on_floor():
		velocity.y = 0 # Remove y velocity when grounded
		airtime = 0
	else:
		velocity.y -= grav * delta # Speed up vertical fall speed when airborne, multiplied by framerate.
		airtime += delta
	velocity.y = clamp(velocity.y, -grav, 9999999)
		
func animation():
	if is_on_floor():
		if not is_equal_approx(abs(input_vector.x) + abs(input_vector.y), 0): ani.play("walk")
		else: ani.play("idle")
	elif jump_check == true:
		ani.play("jump")
		jump_check = false
	elif ani.current_animation != "jump": ani.play("air")
	

	
func quick_drop():
	if Input.is_action_just_pressed("quick_drop") and !is_on_floor(): velocity.y = -grav/2.0

func camera():
	# Handle camlock
	if Input.is_action_just_pressed("camlock"):
		if cam_mode != "camlock":
			cam_mode = "camlock"
			camlock_ui.show()
		else:
			camlock_ui.hide()
			if Input.is_action_pressed("rmb"): cam_mode = "move"
			else: cam_mode = "none"

	if cam_mode != "camlock":
		cam.position.x = 0
		if Input.is_action_pressed("rmb"): cam_mode = "move"
		else: cam_mode = "none"
		camlock_ui.hide()
	else: cam.position.x = 1 if zoom != 0 else 0
	
	if cam_mode == "camlock": rotation.y = rig.rotation.y
	
	# Handle zoom
	
	if Input.is_action_just_pressed("scroll_up"): zoom -= 2.5
	elif Input.is_action_just_pressed("scroll_down"): zoom += 2.5
	
	zoom = clamp(zoom, 0, 50)
	if zoom == 0: visual.hide()
	else: visual.show()
	
	cam.position.z = zoom
	
func player_rotation(delta):
	if cam_mode == "camlock": return
	offset = vector2_to_deg(input_vector)
	target_angle = rig.rotation_degrees.y + offset
	find_shortest_turn()
	if input_vector != Vector2.ZERO: rotation_degrees.y = lerp(rotation_degrees.y, target_angle, rotation_speed * delta)
	
func handle_fuel(delta):
	fuel -= delta
	if fuel < -0.25: death("fuel")
	else:
		$"../ui/vignette_fuel".modulate.a = 1 - abs(fuel * 0.333)
		fuel_label.text = str(snappedf(clamp(fuel, 0.0, 9999), 0.1))
	
func set_variables(delta):
	rig.position = position + Vector3(0, 1.5, 0)
	$"../ui/death_ui/cover".color.r -= delta * 2
	$"../ui/death_ui/cover".color.g -= delta * 2
	$"../ui/death_ui/cover".color.b -= delta * 2

func handle_restart(delta):
	if Input.is_action_pressed("restart"): restart_juice += delta 
	else: restart_juice = 0
	
	if restart_juice > 0.5:
		root.restart()
		restart_juice = -9999

# ABILITIES #

func do_ability():
	
	if ability_buffered and not Input.is_action_pressed("ability"):
		ability_buffered = false
		ability_buffer_active = false
	elif not ability_buffered and Input.is_action_pressed("ability"):
		ability_buffered = true
		ability_buffer_active = true
	
	if ability_buffer_active == false or tsla < 0.04 or ability_list.is_empty(): return
	
	ability_buffer_active = false
	var ability = ability_list[0]
	
	var type = ability[0]
	var value = ability[1]
	var orb = ability[2]
	
	if type == "dash":
		var normalized_input_vector = get_input_vector()
		if normalized_input_vector == Vector2.ZERO: normalized_input_vector = Vector2(0, -1)
		velocity += get_rig_basis() * Vector3(normalized_input_vector.x * value, 0, normalized_input_vector.y * value)
		if velocity.y <= 1: velocity.y = 1

	elif type == "jump":
		velocity.y = value
		ani.play("jump")
		jump_check = true
		coyote = 1
		
	orb.timer.start()
	ability_list.pop_front()

func _on_area_entered(area: Area3D) -> void:
	if area.editor_description == "orb": orb_hit(area)

func disable_orb(orb):
	orb.visible = false
	orb.collider.call_deferred("set", "disabled", true)

func orb_hit(area):
	
	if area.type == "dash" or area.type == "jump":
		ability_list.append([area.type, area.value, area])
	
	elif area.type == "stat_speed": speed = area.value
	elif area.type == "stat_jump": jump_power = area.value
	elif area.type == "fuel":
		if fuel >= 0: fuel += area.value
		else: death(fuel)
		
	elif area.type == "end":
		if fuel >= 0: death("win")
		else: death(fuel)
	disable_orb(area)

	
# DEBUG #

func debug(delta):
	$"../debug/target_angle".rotation_degrees.y = target_angle
	$"../debug/target_angle".position = position + Vector3(0, 1.5, 0)
	
	$"../ui/debug/speed".text = "Speed: " + str(snappedf(Vector2(velocity.x, velocity.z).length(), 0.1))
	
	# Handle FPS counter #
	
	fps_list.append(1 / delta)
	
	if fps_list.size() == 200:
		fps_average = 0
		for value in fps_list:
			fps_average += value
		fps_average = fps_average / 200
		$"../ui/debug/fps".text = "FPS: " + str(int(fps_average))
		fps_list = []
#endregion
