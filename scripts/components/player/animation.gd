extends Node

@onready var vars: Node = $"../shared_variables"

@onready var cambase: Node3D = $"../../cambase"

@onready var anim: AnimationPlayer = $"../../body/visual/anim"
@onready var player: CharacterBody3D = $"../../body"

func animate() -> void:
	if player.is_on_floor():
		if player.velocity == Vector3.ZERO: play_animation("idle")
		else: play_animation("walk")
	else: if not anim.current_animation == "jump": play_animation("air")

	# ORIENT PLAYER #
	if vars.camlock:
		if vars.camlock: player.rotation_degrees.y = cambase.rotation_degrees.y
		
	else: # RUN TURNING CODE #
		if not (is_zero_approx(player.velocity.x) and is_zero_approx(player.velocity.z)): # Only when not in camlock #
			var offset: float = vec2_to_deg(Input.get_vector("left", "right", "front", "back"))
			
			var player_angle: float = player.rotation_degrees.y
			var target_angle: float = cambase.rotation_degrees.y + offset
			

			target_angle = fmod(target_angle, 360.0)
			
			# FIND CLOSEST ANGLE #
			target_angle -= 360
			for count: int in range(3):
				if abs(target_angle + 360 - player_angle) < abs(target_angle - player_angle): target_angle += 360
			
			var difference: float = player_angle - target_angle 
			
			player.rotation_degrees.y -= difference * 0.01 # Multiplication each frame, maybe optimizable?


func vec2_to_deg(value: Vector2) -> int:
	match value:
		Vector2(0, -1): return 0
		Vector2(-1, 0): return 90
		Vector2(0, 1): return 180
		Vector2(1, 0): return 270
		
	if value.x < -0.5 and value.y < -0.5: return 45
	elif value.x < -0.5 and value.y > 0.5: return 135
	elif value.x > 0.5 and value.y > 0.5: return 235
	elif value.x > 0.5 and value.y < -0.5: return 315
	
	print(value)
	return 0

func play_animation(anim_name: String) -> void:
	if not anim.current_animation == anim_name: anim.play(anim_name)
	
	
