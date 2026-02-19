class_name StateMachine
extends Node

@export var initial_state: State

var current_state : State
var states : Dictionary = {}

func _ready() -> void:
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.transitioned.connect(_on_state_transitioned)
	
	if initial_state:
		initial_state.enter()
		current_state = initial_state

func _process(delta: float) -> void:
	if current_state:
		current_state.process_frame(delta)

func _physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_process_frame(delta)

func _on_state_transitioned(from_state: State, to_state: State):
	if from_state != current_state:
		return
	
	var new_state = states.get(to_state.name.to_lower())
	if not new_state:
		return
		
	if current_state:
		current_state.exit()
	
	new_state.enter()
	current_state = new_state
