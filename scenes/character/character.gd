class_name Character
extends CharacterBody2D

@onready var sprite: Sprite2D = $Sprite

func _ready() -> void:
	if not self.is_in_group("characters"):
		self.add_to_group("characters")
	
	TurnManager.add_character(self)

func move(direction: Vector2) -> void:
	global_position += direction * Constants.TILE_SIZE
	sprite.global_position -= direction * Constants.TILE_SIZE
	
	var tween = create_tween()
	tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.tween_property(sprite, "global_position", global_position, Constants.MOVE_SPEED).set_trans(Tween.TRANS_SINE)
