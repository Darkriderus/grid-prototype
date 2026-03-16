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

const inventory_menu_scene = preload("uid://dy7s6c7w2b12c")

@export var reticle: Reticle
@export var map: Map

func get_item(window_title: String, inventory: InventoryComponent, evaluate_for_next_step: bool = false) -> Entity:
	if inventory.items.is_empty():
		await get_tree().physics_frame
		MessageLog.send_message("No items in inventory.", GameColors.IMPOSSIBLE)
		return null
	var inventory_menu: InventoryMenu = inventory_menu_scene.instantiate()
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
	

func get_action(player: Entity) -> Action:
	var action: Action = null
	
	for direction in directions:
		if Input.is_action_just_pressed(direction):
			var offset: Vector2i = directions[direction]
			action = BumpAction.new(player, offset.x, offset.y)
		
	if Input.is_action_just_pressed("wait"):
		action = WaitAction.new(player)
	
	if Input.is_action_just_pressed("view_history"):
		get_parent().transition_to(InputHandler.InputHandlers.HISTORY_VIEWER)
			
	if Input.is_action_just_pressed("pickup"):
		var visible_lootables := player.map_data.get_visible_lootable_entities()
		var lootable_in_range : Array[Entity] = visible_lootables.filter(func (e : Entity): return player.distance(e.grid_position) == 1)
		
		var target : Vector2i = await get_grid_position(player, 0, lootable_in_range)
		var offset : Vector2i = target - player.grid_position
		print(offset)
		action = PickupAction.new(player, offset.x, offset.y)
		
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
		var selected_item: Entity = await get_item("Select an item to drop", player.inventory_component)
		action = DropItemAction.new(player, selected_item)
	
	if Input.is_action_just_pressed("activate"):
		action = await activate_item(player)
		
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
		if not player.equipment_component.get_item_from_slot(EquippableComponent.EquipmentType.RANGED_WEAPON):
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

	if Input.is_action_just_pressed("descend"):
		action = TakeStairsAction.new(player)
	
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
	return selected_position
	
	
