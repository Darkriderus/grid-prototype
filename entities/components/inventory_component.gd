class_name InventoryComponent
extends Component

var items: Array[Entity]
var capacity: int


var base_weight_limit : float
var weight_limit : float:
	get:
		var limit = base_weight_limit
		if entity.equipment_component:
			for equipment : Entity in entity.equipment_component.slots.values():
				if equipment.equippable_component:
					limit += equipment.equippable_component.weight_carry_increase
		return limit
var current_weight: float:
	get:
		var weight := 0.0
		for item in items:
			weight += item.item_component.weight
		return weight

var base_carry_slot_limit : int
var carry_slot_limit : int:
	get:
		var limit := base_carry_slot_limit
		if entity.equipment_component:
			for equipment : Entity in entity.equipment_component.slots.values():
				if equipment.equippable_component:
					limit += equipment.equippable_component.carry_slot_increase
		return limit
var current_carry_slots: int:
	get:
		var carry_slots := 0
		for item in items:
			carry_slots += item.item_component.slots
		return carry_slots
		
var delete_if_empty: bool


func has_space_for_item(item: Entity) -> bool:
	var item_info := item.item_component
	var has_enough_weight := (current_weight + item_info.weight) <= weight_limit
	var has_enough_carry_slots := (current_carry_slots + item_info.slots) <= carry_slot_limit
	
	return has_enough_carry_slots and has_enough_weight

func drop(item: Entity) -> Entity:
	if entity.equipment_component != null and item.is_equippable() and entity.equipment_component.get_item_from_slot(item.equippable_component.equipment_type) == item:
		entity.equipment_component.toggle_equip(item, true)
	entity.inventory_component.items.erase(item)
	entity.changed.emit()
	return item
	
func pickup(item: Entity) -> Entity:
	entity.inventory_component.items.append(item)
	entity.changed.emit()
	return item

func _init(definition: InventoryComponentDefinition) -> void:
	items = []
	capacity = definition.capacity
	base_weight_limit = definition.weight_limit
	base_carry_slot_limit = definition.carry_slot_limit
	delete_if_empty = definition.delete_if_empty

func get_items_by_type(type: Entity.EntityKey) -> Array[Entity]:
	var type_items : Array[Entity] = []
	for item in items:
		if item.key == type:
			type_items.append(item)
	return type_items

func has_item_type(type: Entity.EntityKey) -> bool:
	return get_items_by_type(type).size() > 0

func get_save_data() -> Dictionary:
	var save_data: Dictionary = {
		"capacity": capacity,
		"items": []
	}
	for item in items:
		save_data["items"].append(item.get_save_data())
	return save_data
	
	
func restore(save_data: Dictionary) -> void:
	capacity = save_data["capacity"]
	for item_data in save_data["items"]:
		var item: Entity = Entity.new(null, Vector2i(-1, -1), Entity.EntityKey.UNKNOWN)
		item.restore(item_data)
		items.append(item)
