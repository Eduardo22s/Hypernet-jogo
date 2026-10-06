class_name StateMachine
extends Node

@export var initial_state: State

var current_state: State


func _ready() -> void:

	for child in get_children():
		if child is State:
			child.state_machine = self
			child.npc = get_parent()

	call_deferred("_start_state")


func _start_state() -> void:
	current_state = initial_state

	if current_state:
		current_state.enter()


func _process(delta: float) -> void:

	if current_state:
		current_state.update(delta)


func transition_to(new_state: State) -> void:

	if new_state == current_state:
		return

	if current_state:
		current_state.exit()

	current_state = new_state

	if current_state:
		current_state.enter()
