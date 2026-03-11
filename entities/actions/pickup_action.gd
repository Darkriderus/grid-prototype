class_name PickupAction
extends Action


func perform() -> bool:
	var inventory: InventoryComponent = entity.inventory_component
	var map_data: MapData = get_map_data()
	
	for lootable in map_data.get_lootable_entities():
		if entity != lootable and entity.grid_position == lootable.grid_position:
			if inventory.items.size() >= inventory.capacity:
				MessageLog.send_message("Your inventory is full.", GameColors.IMPOSSIBLE)
				return false
				
			for item in lootable.inventory_component.items:
				lootable.inventory_component.drop(item, true)
	
	for item in map_data.get_items():
		if entity.grid_position == item.grid_position:
			if inventory.items.size() >= inventory.capacity:
				MessageLog.send_message("Your inventory is full.", GameColors.IMPOSSIBLE)
				return false
			
			map_data.entities.erase(item)
			item.get_parent().remove_child(item)
			inventory.items.append(item)
			MessageLog.send_message(
				"You picked up the %s!" % item.get_entity_name(),
				Color.WHITE
			)
			return true
	
	MessageLog.send_message("There is nothing here to pick up.", GameColors.IMPOSSIBLE)
	return false
