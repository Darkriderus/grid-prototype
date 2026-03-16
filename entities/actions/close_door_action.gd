class_name CloseDoorAction
extends ActionWithDirection


func perform() -> bool:
	var target_tile := entity.map_data.get_tile(offset)
	
	if not target_tile or not target_tile.is_open_door():
		if entity == get_map_data().player:
			MessageLog.send_message("No door to close.", GameColors.IMPOSSIBLE)
		return false
	
	target_tile.set_tile_type(Tile.TileTypeKeys.DOOR)
	entity.map_data.setup_pathfinding()
	return true
