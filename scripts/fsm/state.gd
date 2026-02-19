class_name State
extends Node

signal transitioned(from_state: State, to_state_name: String)

@export var character : CharacterBody2D

func enter() -> void:
	pass

func exit() -> void:
	pass
	
func process_frame(delta: float):
	return null
	
func physics_process_frame(delta: float):
	return null
