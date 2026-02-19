extends Node

@export var characters : Array[CharacterBody2D] = []
var current_turn_character : CharacterBody2D:
	set(value):
		current_turn_character = value
		Signals.turn_started.emit(current_turn_character)

func initialize() -> void:
	for character : CharacterBody2D in get_tree().get_nodes_in_group("characters"):
		add_character(character)
	
	Signals.turn_ended.connect(_on_turn_ended)
	
	current_turn_character = characters[0]


func _on_turn_ended(character: CharacterBody2D):
	if character == current_turn_character:
		var next_turn_character_idx = (characters.find(character) + 1) % characters.size()
		current_turn_character = characters[next_turn_character_idx]

func add_character(character: CharacterBody2D):
	if not characters.has(character):
		characters.append(character)
	Signals.character_added.emit(character)
	
	
func remove_character(character: CharacterBody2D):
	if characters.has(character):
		characters.erase(character)
	Signals.character_removed.emit(character)
