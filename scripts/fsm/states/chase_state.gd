class_name ChaseState
extends State

var player_character : Player

func enter() -> void:
	player_character = get_tree().get_first_node_in_group("player") as Player
	print("Entered Chase")
	
func exit() -> void:
	print("Exit Chase")

func physics_process_frame(delta: float):
	if not character:
		return
	if TurnManager.current_turn_character == character:
		TurnManager.end_turn(character)
	
