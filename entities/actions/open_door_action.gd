class_name OpenDoorAction
extends ActionWithDirection

func perform() -> bool:
	var target_tile := entity.map_data.get_tile(offset)
	
	if not target_tile or not target_tile.is_closed_door():
		if entity == get_map_data().player:
			MessageLog.send_message("No door to open.", GameColors.IMPOSSIBLE)
		return false
	
	target_tile.set_tile_type(Tile.TileTypeKeys.DOOR_OPEN)
	
	entity.end_turn()

	entity.map_data.setup_pathfinding()
	return true
