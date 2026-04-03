class_name PickupAction
extends ActionWithTarget


func perform() -> bool:
	var map_data: MapData = get_map_data()
	
	var target_containers : Array[Entity] = map_data.get_lootable_entities_at_location(target.grid_position)
	for container in target_containers:
		if container.inventory_component.items.has(target):
			container.inventory_component.drop(target)
			
	entity.inventory_component.pickup(target)
	MessageLog.send_message(
				"You picked up the %s!" % target.get_entity_name(),
				Color.WHITE
			)	

	entity.end_turn()
	# TODO: Make clean
	#entity.play_animation("walk")
	#entity.entity_scene.animation_player.animation_finished.connect(func(_name): entity.end_turn(), CONNECT_ONE_SHOT)
	return true
