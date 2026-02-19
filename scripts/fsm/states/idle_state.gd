class_name IdleState
extends State

var player_character : Player

func enter() -> void:
	player_character = get_tree().get_first_node_in_group("player") as Player
	character.sight_radius.body_entered.connect(_on_sight_radius_body_entered)
	
	print("Entered Idle")
	
	
func exit() -> void:
	character.sight_radius.body_entered.disconnect(_on_sight_radius_body_entered)
	
	print("Exit Idle")
	
func physics_process_frame(delta: float):
	if not character:
		return
		
	if TurnManager.current_turn_character == character:
		var direction_to_move = Direction.ALL.pick_random()
		
		print("Turn: ", character.name)
		character.move(direction_to_move)
		
		TurnManager.end_turn(character)
		
func _on_sight_radius_body_entered(body: Node2D) -> void:
	if body is Player:
		print("See you", character.name, body.name)
		transitioned.emit(self, "Chase")
		
