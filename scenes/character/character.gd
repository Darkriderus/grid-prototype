class_name Character
extends CharacterBody2D

@onready var sprite: Sprite2D = $Sprite
@export var sight_radius: Area2D
@onready var animation_player: AnimationPlayer = %AnimationPlayer

var tween: Tween

func _ready() -> void:
	if not self.is_in_group("characters"):
		self.add_to_group("characters")
	
	TurnManager.add_character(self)
	
	animation_player.stop()
	animation_player.play("idle")

func move(direction: Vector2) -> void:
	animation_player.stop()
	animation_player.play("schmirb_walk")
	
	global_position += direction * Constants.TILE_SIZE
	sprite.global_position -= direction * Constants.TILE_SIZE
	
	tween = create_tween()
	tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.tween_property(sprite, "global_position", global_position, Constants.MOVE_SPEED).set_trans(Tween.TRANS_SINE)
	tween.tween_callback(_turn_end)
	
func _turn_end():
	animation_player.stop()
	animation_player.play("idle")
	
	print("Char Turn ended: ", name)
