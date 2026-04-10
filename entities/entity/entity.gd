class_name Entity
extends Node2D

signal changed
signal turn_done

var has_finished_turn: bool:
	set(value):
		has_finished_turn = value
		if has_finished_turn:
			turn_done.emit()
		
const ENTITY_SCENE_PREFAB = preload("uid://cc4g2j2qdymr7")
var entity_scene : EntityScene

enum AIType {INANIMATE, HOSTILE, NO_AI}

enum EntityType {CORPSE, ITEM, ACTOR}

#TODO: Rename to DefinitionKey
enum EntityKey {
	UNKNOWN,
	# Actors
	PLAYER,
	GOBLIN,
	
	# Weapons
	SHORT_SWORD,

	# Armors
	CHAINMAIL,

	# Containers
	CHEST,
	DROPPED,
	
	# Ammo
	ARROWS,
	
	# Others
	NOTHING
}

#TODO: Rename to DefinitionPaths
const ENTITY_DEFINITION_PATHS := {
	EntityKey.PLAYER: "uid://dgtkb8ig8pwt0",
	EntityKey.CHEST: "uid://b4cui42b8sdjs",
	EntityKey.CHAINMAIL: "uid://b30i43g57dutp",
	EntityKey.DROPPED: "uid://dopb45xye6uny",
	EntityKey.SHORT_SWORD: "uid://bap1hnuwsn3ei",
	EntityKey.GOBLIN: "uid://bx7hkrlvbtfii",
	EntityKey.ARROWS: "uid://b648m8ilj8brl"
}

var key: EntityKey

var _definition: EntityDefinition
var entity_name: String
var blocks_movement: bool
var map_data: MapData

var stat_component: StatComponent
var ai_component: BaseAIComponent
var consumable_component: ConsumableComponent
var equippable_component: EquippableComponent
var item_component: ItemComponent
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

var texture: Texture2D:
	get:
		return entity_scene.texture
	set(value):
		entity_scene.texture = value

func _init(_map_data: MapData, _start_position: Vector2i, _key: EntityKey = EntityKey.UNKNOWN) -> void:
	if not entity_scene:
		entity_scene = ENTITY_SCENE_PREFAB.instantiate()
		add_child(entity_scene)
	
	grid_position = _start_position
	map_data = _map_data
	if _key != EntityKey.UNKNOWN:
		set_entity_definition(_key)
	
	
func set_entity_definition_by_resource(entity_definition: EntityDefinition) -> void:
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
	
	if entity_definition.stat_definition:
		stat_component = StatComponent.new(entity_definition.stat_definition)
		add_child(stat_component)
	
	if entity_definition.inventory_definition:
		inventory_component = InventoryComponent.new(entity_definition.inventory_definition)
		add_child(inventory_component)
		
	if entity_definition.level_info:
		level_component = LevelComponent.new(entity_definition.level_info)
		add_child(level_component)
		
	if entity_definition.equipment_definition:
		equipment_component = EquipmentComponent.new(entity_definition.equipment_definition)
		add_child(equipment_component)
		equipment_component.entity = self
		equipment_component.generate_items(entity_definition.equipment_definition)
		
	var item_definition: ItemComponentDefinition = entity_definition.item_definition
	if item_definition:
		if item_definition is ConsumableComponentDefinition:
			_handle_consumable(item_definition)
		elif item_definition is EquippableComponentDefinition:
			equippable_component = EquippableComponent.new(item_definition)
			
		item_component = ItemComponent.new(item_definition)

	
func set_entity_definition(_key: EntityKey) -> void:
	key = _key
	var entity_definition: EntityDefinition = load(ENTITY_DEFINITION_PATHS[key])
	set_entity_definition_by_resource(entity_definition)


func move(move_offset: Vector2i) -> void:
	map_data.unregister_blocking_entity(self)
	grid_position += move_offset
	#play_animation("walk")
	#entity_scene.animation_player.animation_finished.connect(func(_name): end_turn(), CONNECT_ONE_SHOT)
	map_data.register_blocking_entity(self)
	
func end_turn():
	has_finished_turn = true
	
func start_turn():
	has_finished_turn = false
	
func play_animation(animation_name: String):
	entity_scene.animation_player.stop()
	entity_scene.animation_player.play(animation_name)

func is_blocking_movement() -> bool:
	return blocks_movement


func is_alive() -> bool:
	return ai_component != null


func has_inventory() -> bool:
	return inventory_component != null


func is_lootable() -> bool:
	return has_inventory() and not is_alive()


func is_equippable():
	return equippable_component != null
	

func is_armor():
	return is_equippable() and EquippableComponent.ArmorEquipmentTypes.has(equippable_component.equipment_type)

func is_weapon():
	return is_equippable() and EquippableComponent.WeaponEquipmentTypes.has(equippable_component.equipment_type)

func get_entity_name() -> String:
	var full_entity_name = entity_name
	
	if is_lootable():
		if inventory_component.items.size() > 0:
			full_entity_name += " (%s items)" % inventory_component.items.size()
		else:
			full_entity_name += " (Empty)"
			
	return full_entity_name

func get_item_name() -> String:
	var full_entity_name := entity_name
	
	if is_armor():
		full_entity_name += " [P: %s]" % equippable_component.protection
	if is_weapon():
		if equippable_component.attack_range > 1:
			full_entity_name += " [Dmg: %s-%s, Rng: %s]" % [equippable_component.min_damage, equippable_component.max_damage, equippable_component.attack_range]
		else:
			full_entity_name += " [Dmg: %s-%s]" % [equippable_component.min_damage, equippable_component.max_damage]
	
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
	if stat_component:
		save_data["stat_component"] = stat_component.get_save_data()
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
	if stat_component and save_data.has("stat_component"):
		stat_component.restore(save_data["stat_component"])
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
