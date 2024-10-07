extends Node

@onready var character_controller = get_parent()

func idle_state():
	character_controller.reset_Jumps()
	if Input.get_action_strength("move_left_%s" % character_controller.id) >= 0.90:
		character_controller.velocity.x = character_controller.run_speed
		character_controller.reset_frame()
		character_controller.turn(false)
		return character_controller.state_machine.states.dash
	if Input.get_action_strength("move_right_%s" % character_controller.id) >= 0.90:
		character_controller.velocity.x = -character_controller.run_speed
		character_controller.reset_frame()
		character_controller.turn(true)
		return character_controller.state_machine.states.dash
	if Input.is_action_pressed("jump_%s" % character_controller.id):
		character_controller.reset_frame()
		return character_controller.state_machine.states.jump_squad
	if Input.is_action_pressed("move_down_%s" % character_controller.id):
		character_controller.reset_frame()
		return character_controller.state_machine.states.crouch
	if character_controller.velocity.x > 0:
		character_controller.velocity.x += -character_controller.traction * 1
		character_controller.velocity.x = clamp(character_controller.velocity.x, 0, character_controller.velocity.x)
	elif character_controller.velocity.x < 0:
		character_controller.velocity.x += character_controller.traction * 1
		character_controller.velocity.x = clamp(character_controller.velocity.x, character_controller.velocity.x, 0)
		
func dash_state():
	if Input.is_action_just_pressed("jump_%s" % character_controller.id):
		character_controller.reset_frame()
		return character_controller.state_machine.states.jump_squad
	if Input.is_action_pressed("move_left_%s" % character_controller.id):
		if character_controller.velocity.x > 0:
			character_controller.reset_frame()
		character_controller.velocity.x = -character_controller.dash_speed
		if character_controller.frame <= character_controller.dash_duration - 1:
			if Input.is_action_just_pressed("move_down_%s" % character_controller.id):
				character_controller.reset_frame()
				return character_controller.state_machine.states.moon_walk
			character_controller.turn(true)
			return character_controller.state_machine.states.dash
		else:
			character_controller.turn(true)
			character_controller.reset_frame()
			return character_controller.state_machine.states.run
	elif Input.is_action_pressed("move_right_%s" % character_controller.id):
		if character_controller.velocity.x < 0:
			character_controller.reset_frame()
		character_controller.velocity.x = character_controller.dash_speed
		if character_controller.frame <= character_controller.dash_duration - 1:
			if Input.is_action_just_pressed("move_down_%s" % character_controller.id):
				character_controller.reset_frame()
				return character_controller.state_machine.states.moon_walk
			character_controller.turn(false)
			return character_controller.state_machine.states.dash
		else:
			character_controller.turn(false)
			character_controller.reset_frame()
			return character_controller.state_machine.states.run
	else:
		if character_controller.frame >= character_controller.dash_duration - 1:
			for state in character_controller.state_machine.states:
				if state != "jump_squad":
					character_controller.reset_frame()
					return character_controller.state_machine.states.idle
			
func jump_squad_state():
	if character_controller.frame == character_controller.jump_squad:
		if Input.is_action_pressed("shield_%s" % character_controller.id):
			if Input.is_action_pressed("move_right_%s" % character_controller.id):
				character_controller.velocity.x = character_controller.air_dodge_speed / character_controller.perfect_wavedash_modifier
			if Input.is_action_pressed("move_left_%s" % character_controller.id):
				character_controller.velocity.x = -character_controller.air_dodge_speed / character_controller.perfect_wavedash_modifier
			character_controller.lag_frames = 6
			character_controller.reset_frame()
			return character_controller.state_machine.states.idle
		character_controller.velocity.x = lerp(character_controller.velocity.x, 0.0, 0.08)
		character_controller.reset_frame()
		return character_controller.state_machine.states.short_hop if not Input.is_action_pressed("jump_%s" % character_controller.id) else character_controller.state_machine.states.full_hop

func short_hop_state():
	character_controller.velocity.y = -character_controller.jump_force
	character_controller.reset_frame()
	return character_controller.state_machine.states.in_air

func full_hop_state():
	character_controller.velocity.y = -character_controller.max_jump_force
	character_controller.reset_frame()
	return character_controller.state_machine.states.in_air
			
func landing_state():
	if character_controller.frame <= character_controller.landing_frames + character_controller.lag_frames:
		if character_controller.frame == 1:
			pass
		if character_controller.velocity.x > 0:
			character_controller.velocity.x = character_controller.velocity.x - (character_controller.traction / 2)
			character_controller.velocity.x = clamp(character_controller.velocity.x, 0, character_controller.velocity.x)
		elif character_controller.velocity.x < 0:
			character_controller.velocity.x = character_controller.velocity.x + (character_controller.traction / 2)
			character_controller.velocity.x = clamp(character_controller.velocity.x, character_controller.velocity.x, 0)
		if Input.is_action_just_pressed("jump_%s" % character_controller.id):
			character_controller.reset_frame()
			return character_controller.state_machine.states.jump_squad
		else:
			character_controller.reset_frame()
			character_controller.lag_frames = 0
			character_controller.reset_Jumps()
			return character_controller.state_machine.states.crouch if Input.is_action_pressed("move_down_%s" % character_controller.id) else character_controller.state_machine.states.idle
	else:
		return character_controller.state_machine.states.idle

func run_state():
	if Input.is_action_just_pressed("jump_%s" % character_controller.id):
		character_controller.reset_frame()
		return character_controller.state_machine.states.jump_squad
	if Input.is_action_just_pressed("move_down_%s" % character_controller.id):
		character_controller.reset_frame()
		return character_controller.state_machine.states.crouch
	if Input.get_action_strength("move_left_%s" % character_controller.id):
		if character_controller.velocity.x <= 0:
			character_controller.velocity.x = -character_controller.run_speed
			character_controller.turn(true)
		else:
			character_controller.reset_frame()
			return character_controller.state_machine.states.character_controller.turn
	elif Input.get_action_strength("move_right_%s" % character_controller.id):
		if character_controller.velocity.x >= 0:
			character_controller.velocity.x = character_controller.run_speed
			character_controller.turn(false)
		else:
			character_controller.reset_frame()
			return character_controller.state_machine.states.character_controller.turn
	else:
		character_controller.reset_frame()
		return character_controller.state_machine.states.idle

func turn_state():
	if Input.is_action_just_pressed("jump_%s" % character_controller.id):
		character_controller.reset_frame()
		return character_controller.state_machine.states.jump_squad
	if character_controller.velocity.x > 0:
		character_controller.turn(true)
		character_controller.velocity.x += -character_controller.traction * 2
		character_controller.velocity.x = clamp(character_controller.velocity.x, 0, character_controller.velocity.x)
	elif character_controller.velocity.x < 0:
		character_controller.turn(false)
		character_controller.velocity.x += character_controller.traction * 2
		character_controller.velocity.x = clamp(character_controller.velocity.x, character_controller.velocity.x, 0)
	else:
		if not Input.is_action_pressed("move_left_%s" % character_controller.id) and not Input.is_action_pressed("move_right_%s" % character_controller.id):
			character_controller.reset_frame()
			return character_controller.state_machine.states.idle
		else:
			character_controller.reset_frame()
			return character_controller.state_machine.states.run

func moon_walk_state():
	if Input.is_action_just_pressed("jump_%s" % character_controller.id):
		character_controller.reset_frame()
		return character_controller.state_machine.states.jump_squad
	elif Input.is_action_pressed("move_left_%s" % character_controller.id) && character_controller.direction() == 1:
		if character_controller.velocity.x > 0:
			character_controller.reset_frame()
		character_controller.velocity.x += -character_controller.air_acceleration * Input.get_action_strength("move_left_%s" % character_controller.id)
		character_controller.velocity.x = clamp(character_controller.velocity.x, -character_controller.dash_speed * 1.4, character_controller.velocity.x)
		if character_controller.frame <= character_controller.dash_duration * 2:
			character_controller.turn(false)
			return character_controller.state_machine.states.moon_walk
		else:
			character_controller.turn(true)
			character_controller.reset_frame()
			return character_controller.state_machine.states.idle
	elif Input.is_action_pressed("move_right_%s" % character_controller.id) && character_controller.direction() == -1:
		if character_controller.velocity.x < 0:
			character_controller.reset_frame()
		character_controller.velocity.x += character_controller.air_acceleration * Input.get_action_strength("move_right_%s" % character_controller.id)
		character_controller.velocity.x = clamp(character_controller.velocity.x, character_controller.velocity.x, character_controller.dash_speed * 1.5)
		if character_controller.frame <= character_controller.dash_duration * 2:
			character_controller.turn(false)
			return character_controller.state_machine.states.moon_walk
		else:
			character_controller.turn(true)
			character_controller.reset_frame()
			return character_controller.state_machine.states.idle
	else:
		if character_controller.frame >= character_controller.dash_duration - 1:
			for state in character_controller.state_machine.states:
				if state != "jump_squad":
					return character_controller.state_machine.states.idle

func walk_state():
	if Input.is_action_just_pressed("jump_%s" % character_controller.id):
		character_controller.reset_frame()
		return character_controller.state_machine.states.jump_squad
	if Input.is_action_just_pressed("move_down_%s" % character_controller.id):
		character_controller.reset_frame()
		return character_controller.state_machine.states.crouch
	if Input.get_action_strength("move_left_%s" % character_controller.id):
		character_controller.velocity.x = -character_controller.walk_speed * Input.get_action_strength("move_left_%s" % character_controller.id)
		character_controller.turn(true)
	elif Input.get_action_strength("move_right_%s" % character_controller.id):
		character_controller.velocity.x = character_controller.walk_speed * Input.get_action_strength("move_right_%s" % character_controller.id)
		character_controller.turn(false)
	else:
		character_controller.reset_frame()
		return character_controller.state_machine.states.idle

func crouch_state():
	if Input.is_action_just_pressed("jump_%s" % character_controller.id):
		character_controller.reset_frame()
		return character_controller.state_machine.states.jump_squad
	if Input.is_action_just_released("move_down_%s" % character_controller.id):
		character_controller.reset_frame()
		return character_controller.state_machine.states.idle
	elif character_controller.velocity.x > 0:
		if character_controller.velocity.x > character_controller.run_speed:
			character_controller.velocity.x += -(character_controller.traction * 4)
			character_controller.velocity.x = clamp(character_controller.velocity.x, 0, character_controller.velocity.x)
		else:
			character_controller.velocity.x += -(character_controller.traction / 2)
			character_controller.velocity.x = clamp(character_controller.velocity.x, 0, character_controller.velocity.x)
	elif character_controller.velocity.x < 0:
		if abs(character_controller.velocity.x) > character_controller.run_speed:
			character_controller.velocity.x += character_controller.traction * 4
			character_controller.velocity.x = clamp(character_controller.velocity.x, character_controller.velocity.x, 0)
		else:
			character_controller.velocity.x += character_controller.traction / 2
			character_controller.velocity.x = clamp(character_controller.velocity.x, character_controller.velocity.x, 0)

func ledge_catch_state():
	if character_controller.frame > 7:
		character_controller.lag_frames = 0
		character_controller.reset_Jumps()
		character_controller.reset_frame()
		return character_controller.state_machine.states.ledge_hold

func ledge_hold_state():
	if character_controller.frame >= 390: # 3.5 seconds!
		self.character_controller.position.y += -25
		character_controller.reset_frame()
		#return character_controller.state_machine.states.tumble
		return character_controller.state_machine.states.in_air
	if Input.is_action_just_pressed("move_down_%s" % character_controller.id):
		character_controller.fast_fall = true
		character_controller.regrab = 30
		character_controller.reset_ledge()
		self.character_controller.position.y += -25
		character_controller.catch = false
		character_controller.reset_frame()
		return character_controller.state_machine.states.in_air
	elif character_controller.ledge_grab_f.get_target_position().x > 0:
		if Input.is_action_just_pressed("move_left_%s" % character_controller.id):
			character_controller.velocity.x = character_controller.air_acceleration / 2
			character_controller.regrab = 30
			character_controller.reset_ledge()
			self.character_controller.position.y += -25
			character_controller.catch = false
			character_controller.reset_frame()
			return character_controller.state_machine.states.in_air
		elif Input.is_action_just_pressed("attack_a_%s" % character_controller.id):
			character_controller.reset_frame()
			return character_controller.state_machine.states.ledge_climb
		elif Input.is_action_just_pressed("move_right_%s" % character_controller.id):
			character_controller.reset_frame()
			return character_controller.state_machine.states.ledge_roll
		elif Input.is_action_just_pressed("jump_%s" % character_controller.id):
			character_controller.reset_frame()
			return character_controller.state_machine.states.ledge_jump  
	elif character_controller.ledge_grab_f.get_target_position().x < 0:
		if Input.is_action_just_pressed("move_right_%s" % character_controller.id):
			character_controller.velocity.x = character_controller.air_acceleration / 2
			character_controller.regrab = 30
			character_controller.reset_ledge()
			self.character_controller.position.y += -25
			character_controller.reset_frame()
			return character_controller.state_machine.states.in_air
		elif Input.is_action_just_pressed("attack_a_%s" % character_controller.id):
			character_controller.reset_frame()
			return character_controller.state_machine.states.ledge_climb
		elif Input.is_action_just_pressed("move_left_%s" % character_controller.id):
			character_controller.reset_frame()
			return character_controller.state_machine.states.ledge_roll
		elif Input.is_action_just_pressed("jump_%s" % character_controller.id):
			character_controller.reset_frame()
			return character_controller.state_machine.states.ledge_jump

func ledge_climb_state():
	if character_controller.frame == 1:
		pass
	if character_controller.frame == 5 or character_controller.frame == 10 or character_controller.frame == 20:
		character_controller.position.y -= 10
	if character_controller.frame == 22:
		character_controller.catch = false
		character_controller.position.y -= 10
		character_controller.position.x += 20 * character_controller.direction()
	if character_controller.frame == 25:
		character_controller.velocity = Vector2.ZERO
		character_controller.move_and_collide(Vector2(character_controller.direction() * 20, 50))
		character_controller.create_hitbox(28.5, 14.25, 12, 361, 0, 50,3,"normal",Vector2(15.75,3.125),0,0.4)
	if character_controller.frame == 30:
		character_controller.reset_ledge()
		character_controller.reset_frame()
		return character_controller.state_machine.states.idle

func ledge_jump_state():
	if character_controller.frame > 14:
		if Input.is_action_just_pressed("attack_a_%s" % character_controller.id):
			character_controller.reset_frame()
			return character_controller.state_machine.states.air_attack
		if Input.is_action_just_pressed("attack_b_%s" % character_controller.id):
			character_controller.reset_frame()
			return character_controller.state_machine.states.special
	if character_controller.frame == 5:
		character_controller.reset_ledge()
		character_controller.position.y -= 20
	if character_controller.frame == 10:
		character_controller.catch = false
		character_controller.position.y -= 20
		if Input.is_action_just_pressed("jump_%s" % character_controller.id) and character_controller.air_jump > 0:
			character_controller.fast_fall = false
			character_controller.velocity.y = -character_controller.double_jump_force
			character_controller.velocity.x = 0
			character_controller.air_jump -= 1
			character_controller.reset_frame()
			return character_controller.state_machine.states.in_air
	if character_controller.frame == 15:
		character_controller.position.y -= 20
		character_controller.velocity.y -= character_controller.double_jump_force
		character_controller.velocity.x += 220 * character_controller.direction()
		if Input.is_action_just_pressed("jump_%s" % character_controller.id) and character_controller.air_jump > 0:
			character_controller.fast_fall = false
			character_controller.velocity.y = -character_controller.double_jump_force
			character_controller.velocity.x = 0
			character_controller.air_jump -= 1
			character_controller.reset_frame()
			return character_controller.state_machine.states.in_air
		if Input.is_action_just_pressed("attack_a_%s" % character_controller.id):
			character_controller.reset_frame()
			return character_controller.state_machine.states.air_attack
	elif character_controller.frame > 15 and character_controller.frame < 20:
		character_controller.velocity.y += character_controller.fall_speed
		if Input.is_action_just_pressed("jump_%s" % character_controller.id) and character_controller.air_jump > 0:
			character_controller.fast_fall = false
			character_controller.velocity.y = -character_controller.double_jump_force
			character_controller.velocity.x = 0
			character_controller.air_jump -= 1
			character_controller.reset_frame()
			return character_controller.state_machine.states.in_air
	if character_controller.frame == 20:
		character_controller.reset_frame()
		return character_controller.state_machine.states.in_air

func ledge_roll_state():
	if character_controller.frame == 1:
		pass
	if character_controller.frame == 5 or character_controller.frame == 10:
		character_controller.position.y -= 5
	if character_controller.frame == 20:
		character_controller.catch = false
		character_controller.position.y -= 5
	if character_controller.frame == 22:
		character_controller.position.y -= 5
		character_controller.position.x += 20 * character_controller.direction()
	if character_controller.frame > 22 and character_controller.frame < 28:
		character_controller.position.x += 5 * character_controller.direction()
	if character_controller.frame == 29:
		character_controller.move_and_collide(Vector2(character_controller.direction() * 20, 50))
	if character_controller.frame == 30:
		character_controller.velocity = Vector2.ZERO
		character_controller.reset_ledge()
		character_controller.reset_frame()
		return character_controller.state_machine.states.idle
		
func hit_stun_state(delta):
	if character_controller.knockback >= 3:
		var bounce = character_controller.move_and_collide(character_controller.velocity * delta)
		if bounce:
			character_controller.velocity = character_controller.velocity.bounce(bounce.get_normal()) * 0.8
			character_controller.hit_stun = round(character_controller.hit_stun * 0.8)
	if character_controller.velocity.y < 0:
		character_controller.velocity.y += (character_controller.v_decay * 0.5) * Engine.time_scale
		character_controller.velocity.y = clamp(character_controller.velocity.y, character_controller.velocity.y, 0)
	if character_controller.velocity.x < 0:
		character_controller.velocity.x += -(character_controller.h_decay * 0.4) * Engine.time_scale
		character_controller.velocity.x = clamp(character_controller.velocity.x, character_controller.velocity.x, 0)
	elif character_controller.velocity.x > 0:
		character_controller.velocity.x -= (character_controller.h_decay * 0.4) * Engine.time_scale
		character_controller.velocity.x = clamp(character_controller.velocity.x, 0, character_controller.velocity.x)
	if character_controller.frame >= character_controller.hit_stun:
		character_controller.reset_frame()
		return character_controller.state_machine.states.in_air
	elif character_controller.frame > 300:
		return character_controller.state_machine.states.in_air
				
func ground_attack_state():
	if Input.is_action_pressed("move_up_%s" % character_controller.id):
		character_controller.reset_frame()
		return character_controller.state_machine.states.up_tilt
	if Input.is_action_pressed("move_down_%s" % character_controller.id):
		character_controller.reset_frame()
		return character_controller.state_machine.states.down_tilt
	if Input.is_action_pressed("move_right_%s" % character_controller.id):
		character_controller.turn(false)
		character_controller.reset_frame()
		return character_controller.state_machine.states.forward_tilt
	if Input.is_action_pressed("move_left_%s" % character_controller.id):
		character_controller.turn(true)
		character_controller.reset_frame()
		return character_controller.state_machine.states.forward_tilt
	character_controller.reset_frame()
	return character_controller.state_machine.states.jab

func air_attack_state():
	character_controller.air_movement()
	if Input.is_action_pressed("move_up_%s" % character_controller.id):
		character_controller.reset_frame()
		return character_controller.state_machine.states.up_air
	if Input.is_action_pressed("move_down_%s" % character_controller.id):
		character_controller.reset_frame()
		return character_controller.state_machine.states.down_air
	match character_controller.direction():
		1:
			if Input.is_action_pressed("move_left_%s" % character_controller.id):
				character_controller.reset_frame()
				return character_controller.state_machine.states.back_air
			if Input.is_action_pressed("move_right_%s" % character_controller.id):
				character_controller.reset_frame()
				return character_controller.state_machine.states.forward_air
		-1:
			if Input.is_action_pressed("move_right_%s" % character_controller.id):
				character_controller.reset_frame()
				return character_controller.state_machine.states.back_air
			if Input.is_action_pressed("move_left_%s" % character_controller.id):
				character_controller.reset_frame()
				return character_controller.state_machine.states.forward_air
	character_controller.reset_frame()
	return character_controller.state_machine.states.neutral_air	
	
func forward_tilt_state():
	if character_controller.frame == 0:
		character_controller.moveset.forward_tilt()
		pass
	if character_controller.frame >= 1:
		if character_controller.velocity.x > 0:
			character_controller.velocity.x += -character_controller.traction * 3
			character_controller.velocity.x = clamp(character_controller.velocity.x, 0, character_controller.velocity.x)
		elif character_controller.velocity.x < 0:
			character_controller.velocity.x += character_controller.traction * 3
			character_controller.velocity.x = clamp(character_controller.velocity.x, character_controller.velocity.x, 0)
	if character_controller.moveset.forward_tilt():
			return character_controller.state_machine.states.idle
		
func up_tilt_state():
	if character_controller.frame == 0:
		character_controller.moveset.up_tilt()
		pass
	if character_controller.frame >= 1:
		if character_controller.velocity.x > 0:
			character_controller.velocity.x += -character_controller.traction * 3
			character_controller.velocity.x = clamp(character_controller.velocity.x, 0, character_controller.velocity.x)
		elif character_controller.velocity.x < 0:
			character_controller.velocity.x += character_controller.traction * 3
			character_controller.velocity.x = clamp(character_controller.velocity.x, character_controller.velocity.x, 0)
	if character_controller.moveset.up_tilt():
			return character_controller.state_machine.states.idle

func down_tilt_state():
	if character_controller.frame == 0:
		character_controller.moveset.down_tilt()
		pass
	if character_controller.frame >= 1:
		if character_controller.velocity.x > 0:
			character_controller.velocity.x += -character_controller.traction * 3
			character_controller.velocity.x = clamp(character_controller.velocity.x, 0, character_controller.velocity.x)
		elif character_controller.velocity.x < 0:
			character_controller.velocity.x += character_controller.traction * 3
			character_controller.velocity.x = clamp(character_controller.velocity.x, character_controller.velocity.x, 0)
	if character_controller.moveset.down_tilt():
		if Input.is_action_pressed("move_down_%s" % character_controller.id):
			character_controller.reset_frame()
			return character_controller.state_machine.states.crouch
		else:
			character_controller.reset_frame()
			return character_controller.state_machine.states.idle

func jab_state():
	if character_controller.frame == 0:
		character_controller.moveset.jab()
		pass
	if character_controller.frame >= 1:
		if character_controller.velocity.x > 0:
			character_controller.velocity.x += -character_controller.traction * 3
			character_controller.velocity.x = clamp(character_controller.velocity.x, 0, character_controller.velocity.x)
		elif character_controller.velocity.x < 0:
			character_controller.velocity.x += character_controller.traction * 3
			character_controller.velocity.x = clamp(character_controller.velocity.x, character_controller.velocity.x, 0)
	if character_controller.moveset.jab():
		if Input.is_action_pressed("attack_a_%s" % character_controller.id):
			character_controller.reset_frame()
			return character_controller.state_machine.states.jab
		else:
			return character_controller.state_machine.states.idle

func neutral_air_state():
	character_controller.air_movement()
	if character_controller.frame == 0:
		character_controller.moveset.neutral_air()
	if character_controller.moveset.neutral_air():
		character_controller.lag_frames = 0
		character_controller.reset_frame()
		return character_controller.state_machine.states.in_air
	else:
		character_controller.lag_frames = character_controller.moveset.lag_frames.Neutral_Air

func up_air_state():
	character_controller.air_movement()
	if character_controller.frame == 0:
		character_controller.moveset.up_air()
	if character_controller.moveset.up_air():
		character_controller.lag_frames = 0
		character_controller.reset_frame()
		return character_controller.state_machine.states.in_air
	else:
		character_controller.lag_frames = character_controller.moveset.lag_frames.Up_Air

func back_air_state():
	character_controller.air_movement()
	if character_controller.frame == 0:
		character_controller.moveset.back_air()
	if character_controller.moveset.back_air():
		character_controller.lag_frames = 0
		character_controller.reset_frame()
		return character_controller.state_machine.states.in_air
	else:
		character_controller.lag_frames = character_controller.moveset.lag_frames.Back_Air

func forward_air_state():
	character_controller.air_movement()
	if Input.is_action_just_pressed("jump_%s" % character_controller.id) and character_controller.air_jump > 0:
		character_controller.fast_fall = false
		character_controller.velocity.x = 0
		character_controller.velocity.y = -character_controller.double_jump_force
		character_controller.air_jump -= 1
		if Input.is_action_pressed("move_left_%s" % character_controller.id):
			character_controller.velocity.x = -character_controller.max_air_speed
		elif Input.is_action_pressed("move_right_%s" % character_controller.id):
			character_controller.velocity.x = character_controller.max_air_speed
		return character_controller.state_machine.states.in_air
	if character_controller.frame == 0:
		character_controller.moveset.forward_air()
	if character_controller.moveset.forward_air():
		character_controller.lag_frames = 30
		character_controller.reset_frame()
		return character_controller.state_machine.states.forward_air
	else:
		character_controller.lag_frames = character_controller.moveset.lag_frames.Forward_Air

func down_air_state():
	character_controller.air_movement()
	if character_controller.frame == 0:
		character_controller.moveset.down_air()
	if character_controller.moveset.down_air():
		character_controller.lag_frames = 0
		character_controller.reset_frame()
		return character_controller.state_machine.states.in_air
	else:
		character_controller.lag_frames = character_controller.moveset.lag_frames.Down_Air
