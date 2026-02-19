class_name Character
extends CharacterBody2D

@onready var sprite: Sprite2D = $Sprite

func _ready() -> void:
	if not self.is_in_group("characters"):
		self.add_to_group("characters")
	
	TurnManager.add_character(self)
	
	Signals.turn_started.connect(_on_turn_started)

func _on_turn_started(character: CharacterBody2D):
	if character != self:
		return
		
	print("My turn! ", self.name) 
	# TODO: Do your stuff (FSM)
	
	Signals.turn_ended.emit(self)
