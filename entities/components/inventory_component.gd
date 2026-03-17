class_name InventoryComponent
extends Component

var items: Array[Entity]
var capacity: int
var delete_if_empty: bool

func _init(definition: InventoryComponentDefinition) -> void:
	items = []
	capacity = definition.capacity
	delete_if_empty = definition.delete_if_empty

func get_items_by_type(type: Entity.EntityKey) -> Array[Entity]:
	var type_items : Array[Entity] = []
	for item in items:
		if item.key == type:
			type_items.append(item)
	return type_items

func has_item_type(type: Entity.EntityKey) -> bool:
	return get_items_by_type(type).size() > 0


# TODO: Rewrite
func drop(item: Entity, silent: bool = false) -> Entity:
	items.erase(item)
	var map_data: MapData = get_map_data()
	map_data.entities.append(item)
	map_data.entity_placed.emit(item)
	item.map_data = map_data
	item.grid_position = entity.grid_position
	if not silent:
		MessageLog.send_message("You dropped the %s." % item.get_entity_name(), Color.WHITE)
		
	return item


func pickup(item: Entity):	
	if items.size() >= capacity:
		MessageLog.send_message("Your inventory is full.", GameColors.IMPOSSIBLE)
		return false
		
	var map_data: MapData = get_map_data()
	map_data.entities.erase(item)
	item.get_parent().remove_child(item)
	items.append(item)
	MessageLog.send_message(
		"You picked up the %s!" % item.get_entity_name(),
		Color.WHITE
	)
	
	return item


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
