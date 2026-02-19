class_name State
extends Node

signal transitioned(from_state: State, to_state: State)

@export var character : CharacterBody2D

func enter() -> void:
	pass

func exit() -> void:
	pass
	
func process_frame(delta: float) -> State:
	return null
	
func physics_process_frame(delta: float) -> State:
	return null
