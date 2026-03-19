extends BaseInputHandler

# TODO: Directions constant?
const directions = {
	"move_up": Vector2i.UP,
	"move_down": Vector2i.DOWN,
	"move_left": Vector2i.LEFT,
	"move_right": Vector2i.RIGHT,
	"move_up_left": Vector2i.UP + Vector2i.LEFT,
	"move_up_right": Vector2i.UP + Vector2i.RIGHT,
	"move_down_left": Vector2i.DOWN + Vector2i.LEFT,
	"move_down_right": Vector2i.DOWN + Vector2i.RIGHT,
}

const INVENTORY_MENU_SCENE = preload("uid://dy7s6c7w2b12c")
const LOOT_MENU_SCENE = preload("uid://dh5x356856lj4")
const CHARACTER_PANEL_SCENE = preload("uid://b75nk2pcefvpa")


@export var reticle: Reticle
@export var map: Map
var player_enabled := true


func _enable_player():
	player_enabled = true


func enter():
	if not SignalBus.player_turn_started.is_connected(_enable_player):
		SignalBus.player_turn_started.connect(_enable_player)
	
func exit():
	if SignalBus.player_turn_started.is_connected(_enable_player):
		SignalBus.player_turn_started.disconnect(_enable_player)


func get_item(window_title: String, inventory: InventoryComponent, evaluate_for_next_step: bool = false) -> Entity:
	if inventory.items.is_empty():
		await get_tree().physics_frame
		MessageLog.send_message("No items in inventory.", GameColors.IMPOSSIBLE)
		return null
	var inventory_menu: InventoryMenu = INVENTORY_MENU_SCENE.instantiate()
	add_child(inventory_menu)
	inventory_menu.build(window_title, inventory)
	get_parent().transition_to(InputHandler.InputHandlers.DUMMY)
	var selected_item: Entity = await inventory_menu.item_selected
	var has_item: bool = selected_item != null
	var needs_targeting: bool = has_item and selected_item.consumable_component and selected_item.consumable_component.get_targeting_radius() != -1
	if not evaluate_for_next_step or not has_item or not needs_targeting:
		await get_tree().physics_frame
		get_parent().call_deferred("transition_to", InputHandler.InputHandlers.MAIN_GAME)
	return selected_item
	
func open_loot_menu(window_title: String, player: Entity, entity_to_loot: Entity) -> void:
	var loot_menu: LootMenu = LOOT_MENU_SCENE.instantiate()
	add_child(loot_menu)
	loot_menu.build(window_title, player, entity_to_loot)
	get_parent().transition_to(InputHandler.InputHandlers.DUMMY)
	await loot_menu.looting_done
	await get_tree().physics_frame
	get_parent().call_deferred("transition_to", InputHandler.InputHandlers.MAIN_GAME)

func open_character_menu(entity: Entity) -> void:
	var character_panel : CharacterPanel = CHARACTER_PANEL_SCENE.instantiate()
	add_child(character_panel)
	character_panel.build(entity)
	get_parent().transition_to(InputHandler.InputHandlers.DUMMY)
	await character_panel.equipment_done
	await get_tree().physics_frame
	get_parent().call_deferred("transition_to", InputHandler.InputHandlers.MAIN_GAME)

func get_action(player: Entity) -> Action:
	var action: Action = null
	
	if not player_enabled:
		return
	
	for direction in directions:
		if Input.is_action_just_pressed(direction):
			var offset: Vector2i = directions[direction]
			action = BumpAction.new(player, offset.x, offset.y)
		
	if Input.is_action_just_pressed("wait"):
		action = WaitAction.new(player)
	
	if Input.is_action_just_pressed("pickup"):
		var visible_lootables := player.map_data.get_visible_lootable_entities()
		var lootable_in_range : Array[Entity] = visible_lootables.filter(func (e : Entity): return e != player and player.distance(e.grid_position) <= 1)
		
		var target : Vector2i = await get_grid_position(player, 0, lootable_in_range)
		
		if target != Vector2i(-1, -1):
			var all_lootables := player.map_data.get_lootable_entities_at_location(target)
			
			if all_lootables.size() > 0:
				var entity_to_loot := all_lootables[0]
				await open_loot_menu(entity_to_loot.entity_name, player, entity_to_loot)
				
				if entity_to_loot.inventory_component.items.size() == 0 and entity_to_loot.inventory_component.delete_if_empty:
					player.map_data.entities.erase(entity_to_loot)
					player.map_data.entity_removed.emit(entity_to_loot)
			else:
				MessageLog.send_message("There is nothing here to pick up.", GameColors.IMPOSSIBLE)
		
	if Input.is_action_just_pressed("open_door"):
		var visible_doors := player.map_data.get_visible_tiles_by_type(Tile.TileTypeKeys.DOOR)
		var doors_in_range : Array[Tile] = visible_doors.filter(func (t : Tile): return player.distance(t.grid_position) == 1)
		#await get_grid_position(player, 0, doors_in_range)
		var target : Vector2i
		if doors_in_range.size() == 1:
			target = doors_in_range[0].grid_position
		else:
			# TODO: Add possibility to select door
			target = player.grid_position
		
		action = OpenDoorAction.new(player, target.x, target.y)
		
	if Input.is_action_just_pressed("close_door"):
		var visible_doors := player.map_data.get_visible_tiles_by_type(Tile.TileTypeKeys.DOOR_OPEN)
		var doors_in_range : Array[Tile] = visible_doors.filter(func (t : Tile): return player.distance(t.grid_position) == 1)
		var target : Vector2i = Vector2i(-1,-1)
		
		if doors_in_range.size() == 1:
			target = doors_in_range[0].grid_position
		elif doors_in_range.size() > 1:
			#await get_grid_position(player, 0, doors_in_range)
			# TODO: Add possibility to select door
			target = player.grid_position
		
		action = CloseDoorAction.new(player, target.x, target.y)
	
	if Input.is_action_just_pressed("drop"):
		var visible_lootables := player.map_data.get_visible_lootable_entities()
		var lootable_in_range : Array[Entity] = visible_lootables.filter(func (e : Entity): return e != player and player.distance(e.grid_position) <= 1)
		
		var target : Vector2i = await get_grid_position(player, 0, lootable_in_range)
		if player.distance(target) > 1:
			MessageLog.send_message("Too far away.", GameColors.IMPOSSIBLE)
		else:
			if target != Vector2i(-1, -1):
				var all_lootables := player.map_data.get_lootable_entities_at_location(target)
				var container : Entity
				if all_lootables.size() == 0:
					container = Entity.new(player.map_data, target, Entity.EntityKey.DROPPED)
					player.map_data.entities.append(container)
					player.map_data.entity_placed.emit(container)
				else:
					container = all_lootables[0]
				
				await open_loot_menu(container.entity_name, player, container)
				
				if container.inventory_component.items.size() == 0 and container.inventory_component.delete_if_empty:
					player.map_data.entities.erase(container)
					player.map_data.entity_removed.emit(container)
	
	if Input.is_action_just_pressed("activate"):
		action = await activate_item(player)
		
	if Input.is_action_just_pressed("inventory"):
		await get_item("Inventory", player.inventory_component)
		
	if Input.is_action_just_pressed("quit") or Input.is_action_just_pressed("ui_back"):
		action = EscapeAction.new(player)
		
	if Input.is_action_just_pressed("look"):
		var entities_in_sight := player.map_data.get_visible_entities()
		
		entities_in_sight.sort_custom(func (a: Entity, b: Entity):
			if player.distance(a.grid_position) < player.distance(b.grid_position):
				return true
			return false
		)
		
		await get_grid_position(player, 0, entities_in_sight)
		
	if Input.is_action_just_pressed("fire_weapon"):
		if not player.equipment_component.get_item_from_slot(EquippableComponent.EquipmentType.RANGED):
			MessageLog.send_message("No ranged weapon equipped.", GameColors.IMPOSSIBLE)
		else:
			var enemies_in_sight := player.map_data.get_visible_actors()
			enemies_in_sight.erase(player)
			enemies_in_sight.sort_custom(func (a: Entity, b: Entity):
				if player.distance(a.grid_position) < player.distance(b.grid_position):
					return true
				return false
			)
			
			var target : Vector2i = await get_grid_position(player, 0, enemies_in_sight)
			var offset : Vector2i = target - player.grid_position
			
			action = RangedAction.new(player, offset.x, offset.y)

	if Input.is_action_just_pressed("display_character_info"):
		open_character_menu(player)
		
	if Input.is_action_just_pressed("descend"):
		action = TakeStairsAction.new(player)
	
	if action:
		player_enabled = false
	
	return action
	

func activate_item(player: Entity) -> Action:
	var selected_item: Entity = await get_item("Select an item to use", player.inventory_component, true)
	if selected_item == null:
		return null
	var target_radius: int = -1
	if selected_item.consumable_component != null:
		target_radius = selected_item.consumable_component.get_targeting_radius()
	if target_radius == -1:
		return ItemAction.new(player, selected_item)
	var target_position: Vector2i = await get_grid_position(player, target_radius)
	if target_position == Vector2i(-1, -1):
		return null
	return ItemAction.new(player, selected_item, target_position)


func get_grid_position(player: Entity, radius: int, tabbable_targets: Array[Entity] = []) -> Vector2i:
	get_parent().transition_to(InputHandler.InputHandlers.DUMMY)
	var selected_position: Vector2i = await reticle.select_position(player, radius, tabbable_targets)
	await get_tree().physics_frame
	get_parent().call_deferred("transition_to", InputHandler.InputHandlers.MAIN_GAME)
	await get_tree().physics_frame
	return selected_position
	
	
