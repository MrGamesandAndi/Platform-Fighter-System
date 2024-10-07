extends Area2D

@onready var parent = get_parent()

var knockback_value
var frame_z = 0
var immune_list = []

const angle_conversion = PI / 180

@export var percentage = 0
@export var weight = 100
@export var base_knockbacn = 40
@export var ratio = 1
@export var width = 300 ##Hitbox width in pixels
@export var height = 400 ##Hitbox height in pixels
@export var damage = 50 ##Amount of damage the hitbox does to opponent
@export var angle = 90 ##Angle the hitbox will launch the opponent at
@export var base_kb = 100 ##Minimum amount of knockback the attack can deliver
@export var kb_scaling = 2 ##Controls how much the knockback increases as damage increases 
@export var duration = 1500 ##Duration of the attack in frames
@export var hitlag_modifier = 1 ##How long the opponent and player will freeze when hitbox collides
@export var type = "normal" ##Effect type that attack can have. Ex: Fire,Ice,Electricity
@export var angle_flipper = 0 ##How the oponent is launched in relation to where the hitbox connects

@onready var hitbox = $"Hitbox Shape"
@onready var parent_state = get_parent().self_state

func set_parameters(_width,_height,_damage,_angle,_base_kb,_kb_scaling,_duration,_type,points,_angle_flipper,_hitlag_modifier,_parent = get_parent):
	self.position = Vector2.ZERO
	immune_list.append(parent)
	immune_list.append(self)
	width = _width
	height = _height
	damage = _damage
	angle = _angle
	base_kb = _base_kb
	kb_scaling = _kb_scaling
	duration = _duration
	type = _type
	self.position = points
	hitlag_modifier = _hitlag_modifier
	angle_flipper = _angle_flipper
	update_extents()
	connect("body_entered", Callable(self, "hitbox_collide"))
	set_physics_process(true)

func hitbox_collide(body):
	if !(body in immune_list):
		immune_list.append(body)
		var char_state
		char_state = body.get_node("StateMachine")
		weight = body.weight
		body.percentage += damage
		knockback_value = knockback(body.percentage, damage, weight, kb_scaling, base_kb)
		s_angle(body)
		angle_decider(body)
		body.knockback = knockback_value
		body.hit_stun = get_hit_stun(knockback_value / 0.3)
		parent.connected = true
		body.reset_frame()
		char_state.state = char_state.states.hit_stun

func update_extents():
	hitbox.shape.size = Vector2(width, height)

func _ready():
	hitbox.shape = RectangleShape2D.new()
	set_physics_process(false)
	parent.connected = false
	pass

func _physics_process(delta):
	if frame_z < duration:
		frame_z += 1
	elif frame_z == duration or parent.self_state != parent_state:
		Engine.time_scale = 1
		queue_free()
		return
		
func get_hit_stun(knockback):
	return floor(knockback * 0.533) #Or 0.4 for shorter hit stun

func knockback(_percentage, _damage, _weight, _kb_scaling, _base_kb):
	percentage = _percentage
	damage = _damage
	weight = _weight
	kb_scaling = _kb_scaling
	base_kb = _base_kb
	return ((((((((percentage / 10) + (percentage * damage / 20)) * (200 / (weight + 100)) * 1.4) + 18) * (kb_scaling)) + base_kb) * 1)) * 0.004

func s_angle(body):
	if angle == 361:
		if knockback_value > 28:
			angle = 40 if !body.is_on_floor() else 38
		else:
			angle = 40 if !body.is_on_floor() else 25
	elif angle == -181:
		if knockback_value > 28:
			angle = 140 if !body.is_on_floor() else 142
		else:
			angle = 140 if !body.is_on_floor() else 155
			
func get_horizontal_decay(angle):
	var decay = 0.051 * cos(angle * angle_conversion)
	decay = round(decay * 100000) / 100000
	decay = decay * 1000
	return decay
	
func get_vertical_decay(angle):
	var decay = 0.051 * sin(angle * angle_conversion)
	decay = round(decay * 100000) / 100000
	decay = decay * 1000
	return abs(decay)
	
func get_horizontal_velocity(knockback, angle):
	var initial_velocity = knockback * 30
	var horizontal_angle = cos(angle * angle_conversion)
	var horizontal_velocity = initial_velocity * horizontal_angle
	horizontal_velocity = round(horizontal_velocity * 100000) / 100000
	return horizontal_velocity
	
func get_vertical_velocity(knockback, angle):
	var initial_velocity = knockback * 30
	var vertical_angle = sin(angle * angle_conversion)
	var vertical_velocity = initial_velocity * vertical_angle
	vertical_velocity = round(vertical_velocity * 100000) / 100000
	return vertical_velocity
			
func angle_decider(body):
	var x_angle
	x_angle = (parent.direction() * (((body.global_position.angle_to_point(parent.global_position)) * 180) / PI)) + 180
	match angle_flipper:
		0: #Sends at the exact knockback angle every time
			body.velocity.x = get_horizontal_velocity(knockback_value, -angle)
			body.velocity.y = get_vertical_velocity(knockback_value, -angle)
			body.h_decay = get_horizontal_decay(-angle)
			body.v_decay = get_vertical_decay(angle)
		1: #Sends away from center of the enemy player
			x_angle = parent.direction() * (((self.global_position.angle_to_point(body.get_parent().global_position)) * 180) / PI)
			body.velocity.x = get_horizontal_velocity(knockback_value, x_angle + 180)
			body.velocity.y = get_vertical_velocity(knockback_value, -x_angle)
			body.h_decay = get_horizontal_decay(angle + 180)
			body.v_decay = get_vertical_decay(x_angle)
		2: #Sends toward center of the enemy player
			x_angle = parent.direction() * (((body.global_position.angle_to_point(self.get_parent().global_position)) * 180) / PI)
			body.velocity.x = get_horizontal_velocity(knockback_value, -x_angle + 180)
			body.velocity.y = get_vertical_velocity(knockback_value, -x_angle)
			body.h_decay = get_horizontal_decay(x_angle + 180)
			body.v_decay = get_vertical_decay(x_angle)
		3: #Horizontal knockback that sends away from the center of the hitbox
			x_angle = (parent.direction() * (((body.global_position.angle_to_point(self.get_parent().global_position)) * 180) / PI)) + 180
			body.velocity.x = get_horizontal_velocity(knockback_value, x_angle)
			body.velocity.y = get_vertical_velocity(knockback_value, -angle)
			body.h_decay = get_horizontal_decay(x_angle)
			body.v_decay = get_vertical_decay(angle)
		4: ##Horizontal knockback that sends towards the center of the hitbox
			x_angle = parent.direction() * (((body.global_position.angle_to_point(self.get_parent().global_position)) * 180) / PI) + 180
			body.velocity.x = get_horizontal_velocity(knockback_value, -x_angle * 180)
			body.velocity.y = get_vertical_velocity(knockback_value, -angle)
			body.h_decay = get_horizontal_decay(angle)
			body.v_decay = get_vertical_decay(angle)
		5: #Reverse horizontal knockback
			body.velocity.x = get_horizontal_velocity(knockback_value, x_angle + 180)
			body.velocity.y = get_vertical_velocity(knockback_value, -angle)
			body.h_decay = get_horizontal_decay(angle + 180)
			body.v_decay = get_vertical_decay(angle)
		6: #Horizontal knockback that sends away from the enemy player
			body.velocity.x = get_horizontal_velocity(knockback_value, x_angle)
			body.velocity.y = get_vertical_velocity(knockback_value, -angle)
			body.h_decay = get_horizontal_decay(x_angle)
			body.v_decay = get_vertical_decay(angle)
		7: #Horizontal knockback that sends towards the enemy player
			body.velocity.x = get_horizontal_velocity(knockback_value, -x_angle + 180)
			body.velocity.y = get_vertical_velocity(knockback_value, -angle)
			body.h_decay = get_horizontal_decay(angle)
			body.v_decay = get_vertical_decay(angle)
