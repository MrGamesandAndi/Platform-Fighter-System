extends StateMachine

func _get_ready():
	pass
	
func _state_logic(delta: float):
	parent.update_frames(delta)
	parent._physics_process(delta)
	if parent.regrab > 0:
		parent.regrab -= 1

func _get_transition(delta: float):
	# parent.move_and_slide(parent.velocity * 2, Vector2.ZERO, Vector2.UP)
	parent.move_and_slide()
	parent.debug_states.text = str(state)
	if parent.is_landing():
		parent.reset_frame()
		return states.landing
	if parent.is_falling():
		return states.in_air
	if parent.ledge():
		parent.reset_frame()
		return states.ledge_catch
	else:
		parent.reset_ledge()
	if Input.is_action_just_pressed("attack_a_%s" % parent.id) && parent.tilt():
		parent.reset_frame()
		return states.ground_attack
	if Input.is_action_just_pressed("attack_a_%s" % parent.id) && parent.aerial():
		parent.reset_frame()
		return states.air_attack
	match state:
		states.idle:
			return parent.states.idle_state()
		states.run:
			return parent.states.run_state()
		states.turn:
			return parent.states.turn_state()
		states.walk:
			return parent.states.walk_state()
		states.dash:
			return parent.states.dash_state()
		states.jump_squad:
			return parent.states.jump_squad_state()
		states.short_hop:
			return parent.states.short_hop_state()
		states.full_hop:
			return parent.states.full_hop_state()
		states.in_air:
			parent.air_movement()
			parent.multiple_jump()
		states.landing:
			return parent.states.landing_state()
		states.moon_walk:
			return parent.states.moon_walk_state()
		states.crouch:
			return parent.states.crouch_state()
		states.ledge_catch:
			return parent.states.ledge_catch_state()
		states.ledge_hold:
			return parent.states.ledge_hold_state()
		states.ledge_climb:
			return parent.states.ledge_climb_state()
		states.ledge_jump:
			return parent.states.ledge_jump_state()
		states.ledge_roll:
			return parent.states.ledge_roll_state()
		states.hit_stun:
			return parent.states.hit_stun_state(delta)
		states.tumble:
			pass
		states.air_attack:
			return parent.states.air_attack_state()
		states.neutral_air:
			return parent.states.neutral_air_state()
		states.up_air:
			return parent.states.up_air_state()
		states.back_air:
			return parent.states.back_air_state()
		states.forward_air:
			return parent.states.forward_air_state()
		states.down_air:
			return parent.states.down_air_state()
		states.special:
			pass
		states.ground_attack:
			return parent.states.ground_attack_state()
		states.down_tilt:
			return parent.states.down_tilt_state()
		states.jab:
			return parent.states.jab_state()
		states.up_tilt:
			return parent.states.up_tilt_state()
		states.forward_tilt:
			return parent.states.forward_tilt_state()
	
func _enter_state(_new_state, _old_state):
	match state:
		states.idle:
			parent.play_animation("idle")
		states.run:
			parent.play_animation("run")
		states.turn:
			parent.play_animation("turn")
		states.walk:
			parent.play_animation("walk")
		states.dash:
			parent.play_animation("dash")
		states.jump_squad:
			parent.play_animation("jump_squad")
		states.in_air:
			parent.play_animation("jump")
		states.landing:
			parent.play_animation("landing")
		states.moon_walk:
			parent.play_animation("walk")
		states.crouch:
			parent.play_animation("crouch")
		states.ledge_catch:
			parent.play_animation("ledge_catch")
		states.ledge_hold:
			parent.play_animation("ledge_hold")
		states.ledge_climb:
			parent.play_animation("ledge_climb")
		states.ledge_jump:
			parent.play_animation("ledge_jump")
		states.ledge_roll:
			parent.play_animation("ledge_roll")
		states.hit_stun:
			parent.play_animation("hit_stun")
		states.jab:
			parent.play_animation("jab")
		states.down_tilt:
			parent.play_animation("down_tilt")
		states.up_tilt:
			parent.play_animation("up_tilt")
		states.forward_tilt:
			parent.play_animation("forward_tilt")
		states.up_air:
			parent.play_animation("up_air")
		states.back_air:
			parent.play_animation("back_air")
		states.forward_air:
			parent.play_animation("forward_air")
		states.down_air:
			parent.play_animation("down_air")
		states.neutral_air:
			parent.play_animation("neutral_air")
		states.tumble:
			pass
		states.special:
			pass
	
func _exit_state(_old_state, _new_state):
	pass
