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

var base_volume_limit : float
var volume_limit : float:
	get:
		var limit = base_volume_limit
		if entity.equipment_component:
			for equipment : Entity in entity.equipment_component.slots.values():
				if equipment.equippable_component:
					limit += equipment.equippable_component.volume_carry_increase
		return limit
var current_volume: float:
	get:
		var volume := 0.0
		for item in items:
			volume += item.item_component.volume
		return volume
		
var delete_if_empty: bool

func _init(definition: InventoryComponentDefinition) -> void:
	items = []
	capacity = definition.capacity
	base_weight_limit = definition.weight_limit
	base_volume_limit = definition.volume_limit
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
