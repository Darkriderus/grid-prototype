class_name CharSprite
extends Node2D

@onready var sprite: Sprite2D = $Sprite
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var tween: Tween

func _ready() -> void:		
	play_animation("characterbody/idle")

func play_animation(anim_name: String):
	animation_player.stop()
	animation_player.play(anim_name)
