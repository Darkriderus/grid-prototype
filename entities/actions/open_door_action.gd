class_name OpenDoorAction
extends ActionWithDirection

# TODO: Refactor Open,Close to one, move animation_finished to entity
func perform() -> bool:
	var target_tile := entity.map_data.get_tile(offset)
	
	if not target_tile or not target_tile.is_closed_door():
		if entity == get_map_data().player:
			MessageLog.send_message("No door to open.", GameColors.IMPOSSIBLE)
		return false
	
	target_tile.set_tile_type(Tile.TileTypeKeys.DOOR_OPEN)
	
	#TODO: Cleanup
	#entity.play_animation("interact_door")
	#entity.entity_scene.animation_player.animation_finished.connect(func(_name): entity.turn_done.emit(), CONNECT_ONE_SHOT)
	entity.end_turn()

	entity.map_data.setup_pathfinding()
	return true
