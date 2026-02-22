extends CharacterBody3D

# ============================================================
# NODE REFERENCES
# ============================================================
#region Nodes
@onready var rig: Node3D = $"../cam_rig"
@onready var cam: Camera3D = $"../cam_rig/cam"
@onready var ani: AnimationPlayer = $visual/ani
@onready var visual: Node3D = $visual
@onready var root: Node3D = $"../.."
@onready var camlock_ui: TextureRect = $"../ui/camlock"
@onready var fuel_label: Label = $"../ui/fuel"
@onready var ui_death_cover: ColorRect = $"../ui/death_ui/cover"
@onready var debug_speed: Label = $"../ui/debug/speed"
@onready var debug_fps: Label = $"../ui/debug/fps"

@onready var vignette_fuel: TextureRect = $"../ui/vignette_fuel"
#var vignette: ShaderMaterial = preload("res://materials/shaders/vignette.tres")
#endregion

# ============================================================
# EXPORTS & CONFIGURATION
# ============================================================
#region Configuration
@export var type: String = "play"

var sens: float = global.sens

# Movement
var speed: float = 20
var jump_power: float = 60
var grav: float = 250

const coyotetime: float = 0.1
const air_control: float = 0.4
const air_multiplier: float = 0.99
const max_fall_speed = -150

# Rotation
const rotation_speed: int = 15
const rotation_threshold: float = 0.1
#endregion

# ============================================================
# STATE VARIABLES
# ============================================================
#region State
var input_vector: Vector2 = Vector2.ZERO
var airtime: float = 0
var coyote: float = 0
var jump_check: bool = false

var fuel: float = 1
var restart_juice: float = 0

var ability_list: Array = []
var ability_buffered: bool = false
var ability_buffer_active: bool = false
var tsla: float = 1 # Time Since Last Ability

var delta_slow: float = 0

# Camera
var cam_mode: String = "none"
var zoom: float = 12.5

# Rotation
var target_angle: float = 0.0
var offset: int = 0

# Debug
var debug: bool = false
var flying: bool = false
var fly_speed: int = 50
var fly_jump: int = 60

var cline: Node = null
#endregion

# ============================================================
# CORE PROCESS FUNCTIONS
# ============================================================
#region Core Process
func _ready() -> void:
	if type == "play": Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	vignette_fuel.show()
	if type == "editor": cline = $"../../ui/cline"

func _physics_process(delta: float) -> void:
	if root.playing:
		get_input_vector()
		player_rotation(delta)
		animation()
		if type == "play": handle_fuel(delta)
		do_ability()
		movement(delta)
		move_and_slide()

func _process(delta: float) -> void:
	# Runs regardless of game state
	camera()
	handle_restart(delta)
	set_variables(delta)
	if type == "editor":
		global.cam_pos = cam.global_position
		$"../forward_indicator".position = position + Vector3(0, 1, -4)

func _unhandled_input(event: InputEvent) -> void:
	
	
	if event is InputEventMouseMotion:
		if cam_mode == "none" and zoom != 0: return
		rig.rotation_degrees.y -= event.relative.x * sens
		rig.rotation_degrees.x -= event.relative.y * sens
		rig.rotation_degrees.x = clamp(rig.rotation_degrees.x, -90, 90)
		
	elif type == "editor":
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed: select()
		if Input.is_action_just_pressed("esc"):
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			$"../../ui/top_bar/items_middle/1".text = "Lock Cursor"
			cam_mode = "none"
		
		if Input.is_action_just_pressed("focus"): $"../../ui/cline".release_focus()
		
	if event is InputEventKey:
		if Input.is_action_pressed("debug") or type == "editor": debug = true
		
		if debug:
			if Input.is_action_just_pressed("fly_slow"):
				if flying and fly_speed == 25: flying = false
				else:
					flying = true
					fly_speed = 25
					fly_jump = 30
			if Input.is_action_just_pressed("fly"):
				if flying and fly_speed == 50: flying = false
				else:
					flying = true
					fly_speed = 50
					fly_jump = 60
			elif Input.is_action_just_pressed("fly_fast"):
				if flying and fly_speed == 100: flying = false
				else:
					flying = true
					fly_speed = 100
					fly_jump = 120
		
			elif Input.is_action_just_pressed("back_to_spawn"):
				position = $"../../map/spawn".position
				
			if flying: noclip(true)
			else: noclip(false)			
			
		
func noclip(value: bool) -> void:
	if value:
		$collider_main.disabled = true
		$collider_left.disabled = true
		$collider_right.disabled = true
	else:
		$collider_main.disabled = false
		$collider_left.disabled = false
		$collider_right.disabled = false
	
#endregion

# ============================================================
# MOVEMENT & PHYSICS
# ============================================================
#region Movement
func movement(delta: float) -> void:
	get_input_vector()
	move(delta)
	vertical_movement(delta)

func move(delta: float) -> void:
	
	if flying: return
	
	var normalized_input_vector: Vector2 = input_vector.normalized()
	var current_speed: float = Vector2(velocity.x, velocity.z).length()

	# Apply air control input
	velocity += get_rig_basis() * Vector3(normalized_input_vector.x * air_control * delta, 0, normalized_input_vector.y * air_control * delta)
	
		
	# Deceleration
	delta_slow += delta * 1000
	var floored_delta_slow: float = floor(delta_slow)
	velocity.x *= air_multiplier ** floored_delta_slow
	velocity.z *= air_multiplier ** floored_delta_slow
	delta_slow -= floored_delta_slow

	# Apply base speed if not significantly over
	if not current_speed >= speed + 0.25:
		velocity = get_rig_basis() * Vector3(normalized_input_vector.x * speed, velocity.y, normalized_input_vector.y * speed)
		delta_slow = 0

func vertical_movement(delta: float) -> void:
	gravity(delta)
	jump(delta)
	quick_drop()
	if flying: flying_physics()

func jump(delta: float) -> void:
	
	if flying: return
	if type == "editor" and cline.has_focus(): return
	
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

func gravity(delta: float) -> void:
	if is_on_floor():
		velocity.y = 0
		airtime = 0
	else:
		velocity.y -= grav * delta
		airtime += delta
	velocity.y = clamp(velocity.y, -grav, 9999999)
	
	if velocity.y < max_fall_speed: velocity.y = max_fall_speed

func quick_drop() -> void:
	if Input.is_action_just_pressed("quick_drop") and !is_on_floor():
		velocity.y = -grav / 2.0
#endregion

func flying_physics() -> void:
	
	velocity.y = 0
	if type == "editor" and cline.has_focus(): return
	
	get_input_vector()
	var normalized_input_vector: Vector2 = input_vector.normalized()
	velocity = get_rig_basis() * Vector3(normalized_input_vector.x * fly_speed, velocity.y, normalized_input_vector.y * fly_speed)
	delta_slow = 0
	
	
	if Input.is_action_pressed("jump"): velocity.y += fly_jump
	if Input.is_action_pressed("sink"): velocity.y -= fly_jump


# ============================================================
# CAMERA & ROTATION
# ============================================================
#region Camera
func camera() -> void:
	# Handle camlock toggle
	if Input.is_action_just_pressed("camlock") and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if cam_mode != "camlock":
			cam_mode = "camlock"
			camlock_ui.show()
			if type == "editor": $"../camlock".show()
		else:
			camlock_ui.hide()
			if type == "editor": $"../camlock".hide()
			cam_mode = "move" if Input.is_action_pressed("rmb") else "none"

	# Apply camera mode
	if cam_mode != "camlock":
		cam.position.x = 0
		if Input.is_action_pressed("rmb"):
			cam_mode = "move"
		else:
			cam_mode = "none"
		camlock_ui.hide()
		if type == "editor": $"../camlock".hide()
	else:
		cam.position.x = 1 if zoom != 0 else 0

	# Sync player rotation in camlock or first-person
	if cam_mode == "camlock" or zoom == 0:
		rotation.y = rig.rotation.y

	# Handle zoom
	if Input.is_action_just_pressed("scroll_up"):
		zoom -= 2.5
	elif Input.is_action_just_pressed("scroll_down"):
		zoom += 2.5

	zoom = clamp(zoom, 0, 50)
	if zoom == 0:
		visual.hide()
	else:
		visual.show()

	cam.position.z = zoom

func player_rotation(delta: float) -> void:
	if cam_mode == "camlock":
		return

	offset = vector2_to_deg(input_vector)
	target_angle = rig.rotation_degrees.y + offset
	find_shortest_turn()

	if input_vector != Vector2.ZERO:
		rotation_degrees.y = lerp(rotation_degrees.y, target_angle, rotation_speed * delta)

func get_rig_basis() -> Basis:
	var old_rotation_x: float = rig.rotation_degrees.x
	rig.rotation_degrees.x = 0
	var rig_basis: Basis = rig.transform.basis
	rig.rotation_degrees.x = old_rotation_x
	return rig_basis

func vector2_to_deg(value: Vector2) -> int:
	match value:
		Vector2(0, 1): return 180
		Vector2(1, 0): return 270
		Vector2(-1, 0):return 90

	if value.x > 0.5 and value.y > 0.5: return 235
	elif value.x < -0.5 and value.y > 0.5: return 135
	elif value.x < -0.5 and value.y < -0.5: return 45
	elif value.x > 0.5 and value.y < -0.5: return 315
		
	return 0


	

func find_shortest_turn() -> void:
	# Normalize target angle to 0-360 range
	target_angle = fmod(target_angle, 360.0)
	if target_angle < 0:
		target_angle += 360.0

	var current_angle: float = fmod(rotation_degrees.y, 360.0)
	var diff: float = target_angle - current_angle

	# Adjust for shortest rotation path (-180 to 180 degrees)
	if diff > 180:
		target_angle -= 360
	elif diff < -180:
		target_angle += 360
#endregion

# ============================================================
# ABILITIES & INTERACTION
# ============================================================
#region Abilities
func do_ability() -> void:
	if ability_buffered and not Input.is_action_pressed("ability"):
		ability_buffered = false
		ability_buffer_active = false
	elif not ability_buffered and Input.is_action_pressed("ability"):
		ability_buffered = true
		ability_buffer_active = true

	if ability_buffer_active == false or tsla < 0.04 or ability_list.is_empty():
		return

	ability_buffer_active = false
	var ability: Array = ability_list[0]
	var ability_type: String = ability[0]
	var value: float = ability[1]
	var orb: Area3D = ability[2]

	if ability_type == "dash":
		var normalized_input_vector: Vector2 = get_input_vector()
		if normalized_input_vector == Vector2.ZERO:
			normalized_input_vector = Vector2(0, -1)
		velocity += get_rig_basis() * Vector3(normalized_input_vector.x * value, 0, normalized_input_vector.y * value)
		if velocity.y <= 1:
			velocity.y = 1
	elif ability_type == "jump":
		velocity.y = value
		ani.play("jump")
		jump_check = true
		coyote = 1

	orb.timer.start()
	ability_list.pop_front()

func _on_area_entered(area: Area3D) -> void:
	if area.is_in_group("orb"): orb_hit(area)

func orb_hit(area: Area3D) -> void:
	if area.type == "dash" or area.type == "jump":
		ability_list.append([area.type, area.value, area])
	elif area.type == "stat_speed":
		speed = area.value
	elif area.type == "stat_jump":
		jump_power = area.value
	elif area.type == "fuel":
		if debug or fuel >= 0:
			fuel += area.value
		else:
			death(fuel)
	elif area.type == "end" and type == "play":
		if fuel >= 0:
			death("win")
		else:
			death(fuel)

	disable_orb(area)

func disable_orb(orb: Area3D) -> void:
	orb.visible = false
	orb.collider.call_deferred("set", "disabled", true)
#endregion

# ============================================================
# GAME STATE & UI
# ============================================================
#region Game State
func handle_fuel(delta: float) -> void:
	fuel -= delta
	if fuel < -0.25 and !debug: death("fuel")

func handle_restart(delta: float) -> void:
	if Input.is_action_pressed("restart"):
		restart_juice += delta
	else:
		restart_juice = 0

	if restart_juice > 0.5 and type == "play":
		root.restart()
		restart_juice = -9999

func set_variables(delta: float) -> void:
	rig.position = position + Vector3(0, 1.5, 0)
	if root.playing == false:
		ui_death_cover.color -= Color(2 * delta, 2 * delta, 2 * delta, 0)

func death(death_type: Variant) -> void:
	$"../ui/death_ui".visible = true
	$"../ui/death_ui/cover".color = Color(1.0, 1.0, 1.0, 0.75)
	$"../cam_rig/cam/shake".shake_node = true
	$"../../sfx/death".play()
	$"../../map/settings/music".stop()
	vignette_fuel.hide()
	root.playing = false
	ani.stop()
	
	if death_type is float:
		$"../ui/death_ui/reason".text = "Late by " + str(abs(snappedf(fuel, 0.001))) + "s"
	else:
		match death_type:
			"fuel": $"../ui/death_ui/reason".text = "Ran out of fuel"
			"win": $"../ui/death_ui/reason".text = "GG! " + str(abs(snappedf(fuel, 0.001))) + "s left"

func animation() -> void:
	if is_on_floor():
		if not is_equal_approx(abs(input_vector.x) + abs(input_vector.y), 0):
			ani.play("walk")
		else:
			ani.play("idle")
	elif jump_check == true:
		ani.play("jump")
		jump_check = false
	elif ani.current_animation != "jump":
		ani.play("air")
#endregion

# ============================================================
# TIMER UPDATES (0.05s interval)
# ============================================================
func _on_update_timer_timeout() -> void:
	# UI Updates
	fuel_label.text = str(snappedf(clamp(fuel, 0.0, 9999), 0.1))
	vignette_fuel.modulate.a = 1 - abs(fuel * 0.333)

	# Debug Updates
	#debug_speed.text = "Speed: " + str(snappedf(Vector2(velocity.x, velocity.z).length(), 0.1))
	debug_fps.text = "FPS: " + str(Engine.get_frames_per_second())

# ============================================================
# UTILITY
# ============================================================
#region Utility
func get_input_vector() -> Vector2:
	if type == "editor" and cline.has_focus(): input_vector = Vector2.ZERO
	else: input_vector = Input.get_vector("left", "right", "front", "back")
	return input_vector
#endregion

#region Editor
func select() -> Node3D: # DeepSeek code because I don't understand ts yet lol
	
	# Only run in editor mode
	if type != "editor" or Input.mouse_mode == Input.MOUSE_MODE_CAPTURED: return

	# Get mouse position in viewport coordinates
	var mouse_pos: Vector2 = get_viewport().get_mouse_position()

	# Create ray from camera through mouse position
	var from: Vector3 = cam.project_ray_origin(mouse_pos)
	var dir: Vector3 = cam.project_ray_normal(mouse_pos)
	var to: Vector3 = from + dir * 2000.0 # Max length

	# Perform raycast
	var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(from, to)
	query.collide_with_areas = true   # include Areas (orbs, triggers)
	
	# Old gizmo code
	"""
	query.collision_mask = 8 # First check if it collides with gizmo
	
	var result: Dictionary = space_state.intersect_ray(query)
	if result: 
		print(result)
		return
	"""	
	query.collide_with_bodies = true  # include PhysicsBody (CSG, walls)
	query.collision_mask = 5 # Layer 1 and 3, doesn't collide with player
	var result: Dictionary = space_state.intersect_ray(query)
	
	if result:
		# Return the collided node (or its parent if it's a collision shape)
		root.selection(result.collider)
		return result.collider
	root.selection(null)
	return null
