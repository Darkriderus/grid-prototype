class_name PickupAction
extends ActionWithDirection


func perform() -> bool:
	var map_data: MapData = get_map_data()
	var selected_position := entity.grid_position + offset
	
	# TODO: Remove this after container rewrite
	for item in map_data.get_items():
		if selected_position == item.grid_position:
			return _pickup_item(item, map_data, null)
		
	var lootable_at_coord := false
	
	for lootable in map_data.get_lootable_entities():
		if entity != lootable and selected_position == lootable.grid_position:
			lootable_at_coord = true
			
			var items_to_drop = lootable.inventory_component.items.duplicate()
			for item in items_to_drop:
				_pickup_item(item, map_data, lootable)
	
	if lootable_at_coord:
		return true
		
	MessageLog.send_message("There is nothing here to pick up.", GameColors.IMPOSSIBLE)
	return false
	
	
func _pickup_item(item: Entity, map_data: MapData, container: Entity):
	var inventory: InventoryComponent = entity.inventory_component
	
	if inventory.items.size() >= inventory.capacity:
		MessageLog.send_message("Your inventory is full.", GameColors.IMPOSSIBLE)
		return false
			
	if container:
		container.inventory_component.drop(item, true)
		
	map_data.entities.erase(item)
	item.get_parent().remove_child(item)
	inventory.items.append(item)
	MessageLog.send_message(
		"You picked up the %s!" % item.get_entity_name(),
		Color.WHITE
	)
	return true
