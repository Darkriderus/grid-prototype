class_name GridLogic
extends Node2D

static var TILE_SIZE : int = 32
static var ANIMATION_SPEED: float = 0.25

@export var grid : Grid

signal grid_changed
var entities : Dictionary[Vector2i, CharacterBody2D]

func get_tile_from_global(global: Vector2) -> Vector2i:
	return grid.background_tilemap.local_to_map(to_local(global))


func get_global_from_tile(tile: Vector2i) -> Vector2:
	return grid.background_tilemap.to_global(grid.background_tilemap.map_to_local(tile))


func get_hovered_tile() -> Vector2i:
	return grid.background_tilemap.local_to_map(get_local_mouse_position())


func add_entity(tile: Vector2i, entity: CharacterBody2D) -> void:
	entities[tile] = entity
	grid_changed.emit()


func remove_entity(tile: Vector2i) -> void:
	if not is_tile_occupied(tile):
		return
		
	entities.erase(tile)
	grid_changed.emit()


func is_tile_occupied(tile: Vector2i) -> bool:
	return entities.has(tile)


func get_all_entities() -> Array[CharacterBody2D]:
	var entity_array: Array[CharacterBody2D] = []
	
	for entity: CharacterBody2D in entities.values():
		if entity:
			entity_array.append(entity)
	
	return entity_array
	

func get_entity_tile(entity: CharacterBody2D) -> Vector2i:
	if entities.values().has(entity):
		return (entities.find_key(entity))
	else:
		return Vector2i(-1, -1)


func is_tile_in_bounds(tile: Vector2i) -> bool:
	return tile.x >= 0 and tile.y >= 0


func move_entity(entity: CharacterBody2D, tile: Vector2i) -> void:
	assert(not is_tile_occupied(tile), "move entity error: Tile to move in is not empty")
	
	if not is_tile_in_bounds(tile):
		return
	
	if entities.values().has(entity):
		remove_entity(entities.find_key(entity))		
	
	add_entity(tile, entity)
