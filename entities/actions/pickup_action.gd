class_name PickupAction
extends ActionWithTarget


func perform() -> bool:
	var map_data: MapData = get_map_data()
	
	var target_containers : Array[Entity] = map_data.get_lootable_entities_at_location(target.grid_position)
	var loot_container : Entity
	for container in target_containers:
		if container.inventory_component.items.has(target):
			loot_container = container
			loot_container.inventory_component.drop(target)
			
	entity.inventory_component.pickup(target)
	MessageLog.send_message(
				"You picked up the %s!" % target.get_entity_name(),
				Color.WHITE
			)	

	if loot_container and loot_container.inventory_component.items.size() == 0 and loot_container.inventory_component.delete_if_empty:
		map_data.entities.erase(loot_container)
		map_data.entity_removed.emit(loot_container)

	entity.end_turn()
	return true
