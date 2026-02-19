class_name ChaseState
extends State

var player_character : Player

func enter() -> void:
	player_character = get_tree().get_first_node_in_group("player") as Player
	character.sight_radius.body_exited.connect(_on_sight_radius_body_exited)
	
func exit() -> void:
	character.sight_radius.body_exited.disconnect(_on_sight_radius_body_exited)
	
func physics_process_frame(delta: float):
	if not character:
		return
	if TurnManager.current_turn_character == character:
		TurnManager.end_turn(character)
	
func _on_sight_radius_body_exited(body: Node2D) -> void:
	if body is Player:
		transitioned.emit(self, "Idle")
