class_name IdleState
extends State

var player_character : Player

func enter() -> void:
	player_character = get_tree().get_first_node_in_group("player") as Player
	print("Entered Idle")
	
func exit() -> void:
	print("Exit Idle")
	
func physics_process_frame(delta: float):
	if not character:
		return
		
	var distance_to_player = (player_character.global_position - character.global_position)
	if distance_to_player.length() < Constants.TILE_SIZE.x * 3:
		transitioned.emit(self, "Chase")
	
