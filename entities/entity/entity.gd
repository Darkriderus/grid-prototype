class_name Entity
extends Sprite2D

enum AIType {INANIMATE, HOSTILE, NO_AI}

enum EntityType {CORPSE, ITEM, ACTOR}

enum EntityKey {
	UNKNOWN,
	PLAYER,
	ORC,
	TROLL,
	HEALTH_POTION,
	LIGHTNING_SCROLL,
	CONFUSION_SCROLL,
	FIREBALL_SCROLL,
	DAGGER,
	SWORD,
	CHAINMAIL,
	LEATHER_ARMOR,
	CROSSBOW,
	CHEST,
	ARROWS,
	NOTHING
}

const ENTITY_DEFINITION_PATHS := {
	EntityKey.PLAYER: "uid://dgtkb8ig8pwt0",
	EntityKey.ORC: "uid://cu5b5e84eg0bu",
	EntityKey.TROLL: "uid://b4kbg7bx30jwl",
	EntityKey.HEALTH_POTION: "uid://bghj1pduyucfc",
	EntityKey.LIGHTNING_SCROLL: "uid://o50ecypopc40",
	EntityKey.CONFUSION_SCROLL: "uid://b6iuqi6lk2imp",
	EntityKey.FIREBALL_SCROLL: "uid://bpl0ttrtq0p58",
	EntityKey.DAGGER: "uid://dj6mgl0pt8ofp",
	EntityKey.SWORD: "uid://cnvy4inyd8arv",
	EntityKey.CHAINMAIL: "uid://cvbk872p5bt0d",
	EntityKey.LEATHER_ARMOR: "uid://467c55dlqcbx",
	EntityKey.CROSSBOW: "uid://cdmvyyqbt7jow",
	EntityKey.CHEST: "uid://b4cui42b8sdjs",
	EntityKey.ARROWS: "uid://demvf2bx0coki"
}

var key: EntityKey

var _definition: EntityDefinition
var entity_name: String
var blocks_movement: bool
var map_data: MapData

var fighter_component: FighterComponent
var ai_component: BaseAIComponent
var consumable_component: ConsumableComponent
var equippable_component: EquippableComponent
var inventory_component: InventoryComponent
var level_component: LevelComponent
var equipment_component: EquipmentComponent

var type: EntityType:
	set(value):
		type = value
		z_index = type
		
var grid_position: Vector2i:
	set(value):
		grid_position = value
		position = Grid.grid_to_world(grid_position)


func _init(map_data: MapData, start_position: Vector2i, key: EntityKey = EntityKey.UNKNOWN) -> void:
	centered = false
	grid_position = start_position
	self.map_data = map_data
	if key != EntityKey.UNKNOWN:
		set_entity_definition(key)
	
	
func set_entity_definition(key: EntityKey) -> void:
	self.key = key
	var entity_definition: EntityDefinition = load(ENTITY_DEFINITION_PATHS[key])
	_definition = entity_definition
	type = _definition.type
	blocks_movement = _definition.is_blocking_movement
	entity_name = _definition.name
	texture = entity_definition.texture
	modulate = entity_definition.color
	
	match entity_definition.ai_type:
		AIType.HOSTILE:
			ai_component = HostileEnemyAIComponent.new()
			add_child(ai_component)
		AIType.NO_AI:
			ai_component = NoAIComponent.new()
			add_child(ai_component)
	
	if entity_definition.fighter_definition:
		fighter_component = FighterComponent.new(entity_definition.fighter_definition)
		add_child(fighter_component)
	
	if entity_definition.inventory_capacity > 0:
		inventory_component = InventoryComponent.new(entity_definition.inventory_capacity)
		add_child(inventory_component)
		
	if entity_definition.level_info:
		level_component = LevelComponent.new(entity_definition.level_info)
		add_child(level_component)
		
	if entity_definition.has_equipment:
		equipment_component = EquipmentComponent.new()
		add_child(equipment_component)
		equipment_component.entity = self
		
	var item_definition: ItemComponentDefinition = entity_definition.item_definition
	if item_definition:
		if item_definition is ConsumableComponentDefinition:
			_handle_consumable(item_definition)
		else:
			equippable_component = EquippableComponent.new(item_definition)


func move(move_offset: Vector2i) -> void:
	map_data.unregister_blocking_entity(self)
	grid_position += move_offset
	map_data.register_blocking_entity(self)


func is_blocking_movement() -> bool:
	return blocks_movement


func is_alive() -> bool:
	return ai_component != null


func has_inventory() -> bool:
	return inventory_component != null


func is_lootable() -> bool:
	return has_inventory() and not is_alive()
	

func get_entity_name() -> String:
	var full_entity_name = entity_name
	
	if is_lootable():
		if inventory_component.items.size() > 0:
			full_entity_name += " (%s items)" % inventory_component.items.size()
		else:
			full_entity_name += " (Empty)"
			
	return full_entity_name


func distance(other_position: Vector2i) -> int:
	var relative: Vector2i = other_position - grid_position
	return maxi(abs(relative.x), abs(relative.y))


func get_save_data() -> Dictionary:
	var save_data: Dictionary = {
		"x": grid_position.x,
		"y": grid_position.y,
		"key": key,
	}
	if fighter_component:
		save_data["fighter_component"] = fighter_component.get_save_data()
	if ai_component:
		save_data["ai_component"] = ai_component.get_save_data()
	if inventory_component:
		save_data["inventory_component"] = inventory_component.get_save_data()
	if equipment_component:
		save_data["equipment_component"] = equipment_component.get_save_data()
	if level_component:
		save_data["level_component"] = level_component.get_save_data()
	return save_data
	
	
func restore(save_data: Dictionary) -> void:
	grid_position = Vector2i(save_data["x"], save_data["y"])
	set_entity_definition(save_data["key"])
	if fighter_component and save_data.has("fighter_component"):
		fighter_component.restore(save_data["fighter_component"])
	if ai_component and save_data.has("ai_component"):
		var ai_data: Dictionary = save_data["ai_component"]
		if ai_data["type"] == "ConfusedEnemyAI":
			var confused_enemy_ai := ConfusedEnemyAIComponent.new(ai_data["turns_remaining"])
			add_child(confused_enemy_ai)
	if level_component and save_data.has("level_component"):
		level_component.restore(save_data["level_component"])
	if inventory_component and save_data.has("inventory_component"):
		inventory_component.restore(save_data["inventory_component"])
	if equipment_component and save_data.has("equipment_component"):
		equipment_component.restore(save_data["equipment_component"])
		
		
func _handle_consumable(consumable_definition: ConsumableComponentDefinition) -> void:
	if consumable_definition is HealingConsumableComponentDefinition:
		consumable_component = HealingConsumableComponent.new(consumable_definition)
	elif consumable_definition is LightningDamageConsumableComponentDefinition:
		consumable_component = LightningDamageConsumableComponent.new(consumable_definition)
	elif consumable_definition is ConfusionConsumableComponentDefinition:
		consumable_component = ConfusionConsumableComponent.new(consumable_definition)
	elif consumable_definition is FireballDamageConsumableComponentDefinition:
		consumable_component = FireballDamageConsumableComponent.new(consumable_definition)
	
	if consumable_component:
		add_child(consumable_component)
	consumable_component.entity = self
