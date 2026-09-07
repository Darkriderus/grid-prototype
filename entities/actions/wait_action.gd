class_name WaitAction
extends Action

func perform() -> bool:
	entity.end_turn()
	return true
