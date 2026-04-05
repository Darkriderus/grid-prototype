class_name WaitAction
extends Action

func perform() -> bool:
	#TODO: clean up
	#entity.play_animation("walk")
	#entity.entity_scene.animation_player.animation_finished.connect(func(_name): entity.turn_done.emit(), CONNECT_ONE_SHOT)
	entity.end_turn()
	return true
