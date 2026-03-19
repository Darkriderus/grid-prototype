class_name ConsumableComponent
extends ItemComponent


func _init(definition: ItemComponentDefinition) -> void:
	super._init(definition)


func get_action(consumer: Entity) -> Action:
	return ItemAction.new(consumer, entity)


func activate(_action: ItemAction) -> bool:
	return false
	
	
func consume(consumer: Entity) -> void:
	var inventory: InventoryComponent = consumer.inventory_component
	inventory.items.erase(entity)
	entity.queue_free()


func get_targeting_radius() -> int:
	return -1
