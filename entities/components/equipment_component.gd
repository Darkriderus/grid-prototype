class_name EquipmentComponent
extends Component

signal equipment_changed

var slots : Dictionary[EquippableComponent.EquipmentType, Entity] = {}
	
func _init(definition: EquipmentComponentDefinition) -> void:
	pass
	
func generate_items(definition: EquipmentComponentDefinition) -> void:
	for slot_key in definition.slots:
		var entity_def := definition.slots[slot_key]
		if entity_def:
			var item := Entity.new(entity.map_data, entity.grid_position, Entity.EntityKey.UNKNOWN)
			item.set_entity_definition_by_resource(entity_def)
			slots[slot_key] = item
		
	
func get_item_from_slot(slot: EquippableComponent.EquipmentType):
	if slots.has(slot):
		return slots[slot]

	var asking_for_left_hand := slot == EquippableComponent.EquipmentType.LEFT_HAND
	var has_right_hand_equipped := slots.has(EquippableComponent.EquipmentType.RIGHT_HAND)
	
	if asking_for_left_hand and has_right_hand_equipped:
		var right_hand_item := slots[EquippableComponent.EquipmentType.RIGHT_HAND]
		return right_hand_item if right_hand_item.equippable_component.two_handed else null
	

func is_item_equipped(item: Entity) -> bool:
	return item in slots.values()
	

func _unequip_from_slot(slot: EquippableComponent.EquipmentType, add_message: bool) -> void:
	var current_item = slots.get(slot)
	
	if add_message:
		MessageLog.send_message("You remove the %s." % current_item.get_entity_name(), Color.WHITE)
	
	slots.erase(slot)
	entity.changed.emit()
	equipment_changed.emit()


func _equip_to_slot(slot: EquippableComponent.EquipmentType, item: Entity, add_message: bool) -> void:
	var current_item = slots.get(slot)
	if current_item:
		_unequip_from_slot(slot, add_message)
	slots[slot] = item
	if add_message:
		MessageLog.send_message("You equip the %s." % item.get_entity_name(), Color.WHITE)
	
	entity.changed.emit()
	equipment_changed.emit()


func toggle_equip(equippable_item: Entity, add_message: bool = true) -> void:
	if not equippable_item.equippable_component:
		return
	var slot: EquippableComponent.EquipmentType = equippable_item.equippable_component.equipment_type
	
	if slots.get(slot) == equippable_item:
		_unequip_from_slot(slot, add_message)
	else:
		_equip_to_slot(slot, equippable_item, add_message)
		
	entity.changed.emit()
		

func get_save_data() -> Dictionary:
	var equipped_indices := []
	var inventory: InventoryComponent = entity.inventory_component
	for i in inventory.items.size():
		var item: Entity = inventory.items[i]
		if is_item_equipped(item):
			equipped_indices.append(i)
	return {"equipped_indices": equipped_indices}
	

func restore(save_data: Dictionary) -> void:
	var equipped_indices: Array = save_data["equipped_indices"]
	var inventory: InventoryComponent = entity.inventory_component
	for i in inventory.items.size():
		if equipped_indices.any(func(index): return int(index) == i):
			var item: Entity = inventory.items[i]
			toggle_equip(item, false)
