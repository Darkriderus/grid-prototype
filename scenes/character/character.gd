class_name Character
extends CharacterBody2D

@export var sight_radius: Area2D
@onready var char_sprite: CharSprite = $CharSprite

var tween: Tween

func _ready() -> void:
	if not self.is_in_group("characters"):
		self.add_to_group("characters")
	
	TurnManager.add_character(self)
	
	char_sprite.play_animation("characterbody/idle")

func move(direction: Vector2) -> void:
	char_sprite.play_animation("characterbody/schmirb_walk")
	global_position += direction * Constants.TILE_SIZE
	char_sprite.sprite.global_position -= direction * Constants.TILE_SIZE
	
	tween = create_tween()
	tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.tween_property(char_sprite.sprite, "global_position", global_position, Constants.MOVE_SPEED).set_trans(Tween.TRANS_SINE)
	tween.tween_callback(_turn_end)
	
func _turn_end():
	char_sprite.play_animation("characterbody/idle")
	
	print("Char Turn ended: ", name)
