extends CharacterBody2D

@export var id = 1
@export var weight = 0
@export var run_speed = 0
@export var dash_speed = 0
@export var dash_duration = 0
@export var jump_squad = 0
@export var walk_speed = 0
@export var gravity = 0
@export var jump_force = 0
@export var max_jump_force = 0
@export var double_jump_force = 0
@export var max_air_speed = 0
@export var air_acceleration = 0
@export var fall_speed = 0
@export var falling_speed = 0
@export var max_fall_speed = 0
@export var traction = 0
@export var roll_distance = 0
@export var air_dodge_speed = 0
@export var up_B_launch_speed = 0
@export var air_jump_max = 0
@export var perfect_wavedash_modifier = 0
@export var hitbox: PackedScene

@onready var debug_states = $State
@onready var ground_l = $GroundL
@onready var ground_r = $GroundR
@onready var ledge_grab_f = $LedgeGrabF
@onready var ledge_grab_b = $LedgeGrabB
@onready var animations = $Sprite/Animations
@onready var moveset = $Moveset
@onready var states = $States
@onready var state_machine = $StateMachine

var stocks = 3
var percentage = 0
var lag_frames = 0
var frame = 0
var fast_fall = false
var last_ledge = false
var regrab = 30
var catch = false
var air_jump = 0
var landing_frames = 0
var self_state
var h_decay
var v_decay
var knockback
var hit_stun
var connected: bool

func create_hitbox(width, height, damage, angle, base_kb, kb_scaling, duration, type, points, angle_flipper, hitlag = 1):
	var hitbox_instance = hitbox.instantiate()
	self.add_child(hitbox_instance)
	if direction() == 1:
		hitbox_instance.set_parameters(width, height, damage, angle, base_kb, kb_scaling, duration, type, points, angle_flipper, hitlag)
	else:
		var flip_x_points = Vector2(-points.x, points.y)
		hitbox_instance.set_parameters(width, height, damage, -angle + 180, base_kb, kb_scaling, duration, type, flip_x_points, angle_flipper, hitlag)
	return hitbox_instance

func update_frames(delta: float):
	frame += 1

func turn(direction: bool):
	var dir = -1 if direction else 1
	$Sprite.flip_h = direction
	ledge_grab_f.set_target_position(Vector2(dir * abs(ledge_grab_f.get_target_position().x),ledge_grab_f.get_target_position().y))
	ledge_grab_f.position.x = dir * abs(ledge_grab_f.position.x)
	ledge_grab_b.position.x = dir * abs(ledge_grab_b.position.x)
	ledge_grab_b.set_target_position(Vector2(dir * abs(ledge_grab_b.get_target_position().x),ledge_grab_b.get_target_position().y))

func direction():
	return 1 if ledge_grab_f.get_target_position().x > 0 else -1

func reset_frame():
	frame = 0
	
func state_includes(state_array):
	for each_state in state_array:
		if state_machine.state == each_state:
			return true
	return false
	
func tilt():
	if state_includes([state_machine.states.idle,state_machine.states.moon_walk,state_machine.states.dash,state_machine.states.run,state_machine.states.walk,state_machine.states.crouch]):
		return true
	else:
		return false

func aerial():
	if state_includes([state_machine.states.in_air, state_machine.states.down_air, state_machine.states.neutral_air]):
		if !(ground_l.is_colliding() and ground_r.is_colliding()):
			return true
		else:
			return false

func play_animation(animation_name):
	animations.play(animation_name)
	
func reset_ledge():
	last_ledge = false
	
func reset_Jumps():
	air_jump = air_jump_max

func _get_ready():
	pass
	
func _physics_process(delta):
	$Frames.text = str(frame)
	self_state = debug_states.text
	
func multiple_jump():
	if Input.is_action_just_pressed("jump_%s" % id) and air_jump > 0:
		fast_fall = false
		velocity.x = 0
		velocity.y = -double_jump_force
		air_jump -= 1
		#velocity.x = -max_air_speed if Input.is_action_pressed("move_left_%s" % id) else max_air_speed	

func is_landing():
	if state_includes([state_machine.states.in_air,state_machine.states.neutral_air,state_machine.states.up_air,state_machine.states.back_air,state_machine.states.forward_air,state_machine.states.down_air]):
		if ground_l.is_colliding() and velocity.y > 0:
			var collider = ground_l.get_collider()
			reset_frame()
			if velocity.y > 0:
				velocity.y = 0
			fast_fall = false
			return true
		elif ground_r.is_colliding() and velocity.y > 0:
			var collider = ground_r.get_collider()
			reset_frame()
			if velocity.y > 0:
				velocity.y = 0
			fast_fall = false
			return true

func is_falling():
	if state_includes([state_machine.states.idle,state_machine.states.dash,state_machine.states.run]):
		if not ground_l.is_colliding() and not ground_r.is_colliding():
			return true

func ledge():
	if state_includes([state_machine.states.in_air]):
		if ledge_grab_f.is_colliding():
			var collider = ledge_grab_f.get_collider()
			if collider.get_node("Label").text == "LedgeL" and !Input.get_action_strength("move_down_%s" % id) > 0.6 and regrab == 0 and !collider.is_grabbed:
				if state_includes([state_machine.states.in_air]):
					if velocity.y < 0:
						return false
				reset_frame()
				velocity = Vector2.ZERO
				self.position.x = collider.position.x - 20
				self.position.y = collider.position.y - 2
				turn(false)
				reset_Jumps()
				fast_fall = false
				#collider.is_grabbed = true
				last_ledge = collider
				return true
			if collider.get_node("Label").text == "LedgeR" and !Input.get_action_strength("move_down_%s" % id) > 0.6 and regrab == 0 and !collider.is_grabbed:
				if state_includes([state_machine.states.in_air]):
					if velocity.y < 0:
						return false
				reset_frame()
				velocity = Vector2.ZERO
				self.position.x = collider.position.x + 20
				self.position.y = collider.position.y + 1
				turn(true)
				reset_Jumps()
				fast_fall = false
				#collider.is_grabbed = true
				last_ledge = collider
				return true
		if ledge_grab_b.is_colliding():
			var collider = ledge_grab_b.get_collider()
			if collider.get_node("Label").text == "LedgeL" and !Input.get_action_strength("move_down_%s" % id) > 0.6 and regrab == 0 and !collider.is_grabbed:
				if state_includes([state_machine.states.in_air]):
					if velocity.y < 0:
						return false
				reset_frame()
				velocity = Vector2.ZERO
				self.position.x = collider.position.x - 20
				self.position.y = collider.position.y - 1
				turn(false)
				reset_Jumps()
				fast_fall = false
				#collider.is_grabbed = true
				last_ledge = collider
				return true
			if collider.get_node("Label").text == "LedgeR" and !Input.get_action_strength("move_down_%s" % id) > 0.6 and regrab == 0 and !collider.is_grabbed:
				if state_includes([state_machine.states.in_air]):
					if velocity.y < 0:
						return false
				reset_frame()
				velocity = Vector2.ZERO
				self.position.x = collider.position.x + 20
				self.position.y = collider.position.y + 1
				turn(true)
				reset_Jumps()
				fast_fall = false
				#collider.is_grabbed = true
				last_ledge = collider
				return true

func air_movement():
	if velocity.y < falling_speed:
		velocity.y += fall_speed
		#and down_buffer == 1 
	if Input.is_action_pressed("move_down_%s" % id) and velocity.y > -150 and not fast_fall:
		velocity.y = max_fall_speed
		fast_fall = true
	if fast_fall:
		set_collision_mask_value(3, false)
		velocity.y = max_fall_speed
	if abs(velocity.x) >= abs(max_air_speed):
		if velocity.x > 0:
			if Input.is_action_pressed("move_left_%s" % id):
				velocity.x += -air_acceleration
			elif Input.is_action_pressed("move_right_%s" % id):
				velocity.x = velocity.x
		if velocity.x < 0:
			if Input.is_action_pressed("move_left_%s" % id):
				velocity.x = velocity.x
			elif Input.is_action_pressed("move_right_%s" % id):
				velocity.x += air_acceleration
	else:
		if Input.is_action_pressed("move_left_%s" % id):
			velocity.x += -air_acceleration
		elif Input.is_action_pressed("move_right_%s" % id):
			velocity.x += air_acceleration
	if not Input.is_action_pressed("move_left_%s" % id) and not Input.is_action_pressed("move_right_%s" % id):
		if velocity.x < 0:
			velocity.x += air_acceleration / 5
		elif velocity.x > 0:
			velocity.x += -air_acceleration / 5
