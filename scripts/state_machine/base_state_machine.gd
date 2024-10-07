extends Node
class_name StateMachine

# Reference to the parent Node
@onready var parent = get_parent()

# Array of States that the State Machine will use
@export var loaded_states:Array[StringName]

# Current State
var state: StringName

# Previous State
var previous_state = null

# Dictionary for manipulating the States
var states: Dictionary = {}

func _ready() -> void:
	for state in loaded_states:
		add_state(state)
	call_deferred("set_state", loaded_states[0])
	_get_ready()
	
func _get_ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	if state != null:
		_state_logic(delta)
		var transition = _get_transition(delta)
		if transition != null:
			set_state(transition)

func _state_logic(_delta: float) -> void:
	pass
	
func _get_transition(_delta: float):
	return null

func _enter_state(_new_state, _old_state) -> void:
	pass
	
func _exit_state(_old_state, _new_state) -> void:
	pass

func set_state(new_state) -> void:
	previous_state = state
	state = new_state
	if previous_state != null:
		_exit_state(previous_state, new_state)
	if new_state != null:
		_enter_state(new_state, previous_state)
		
func add_state(state_name) -> void:
	states[state_name] = state_name
