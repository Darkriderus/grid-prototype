class_name PopupAnimation
extends Sprite2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	animation_player.play("hit")


func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	queue_free()
