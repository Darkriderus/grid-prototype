class_name CloseDoorAction
extends ActionWithDirection


func perform() -> bool:
	var target_tile := entity.map_data.get_tile(offset)
	
	if not target_tile or not target_tile.is_open_door():
		if entity == get_map_data().player:
			MessageLog.send_message("No door to close.", GameColors.IMPOSSIBLE)
		return false
	
	target_tile.set_tile_type(Tile.TileTypeKeys.DOOR)
	
	#TODO: clean up
	#entity.play_animation("interact_door")
	#entity.entity_scene.animation_player.animation_finished.connect(func(_name): entity.turn_done.emit(), CONNECT_ONE_SHOT)
	
	entity.end_turn()
	entity.map_data.setup_pathfinding()
	return true
