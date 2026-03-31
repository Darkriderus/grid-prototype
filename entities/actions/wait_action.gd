class_name WaitAction
extends Action

func perform() -> bool:
	entity.play_animation("walk")
	entity.entity_scene.animation_player.animation_finished.connect(func(_name): entity.turn_done.emit(), CONNECT_ONE_SHOT)

	return true
