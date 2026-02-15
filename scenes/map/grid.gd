class_name Grid
extends TileMapLayer

@export var logic : GridLogic

func _ready() -> void:
	for entity : CharacterBody2D in get_tree().get_nodes_in_group("entities"):
		logic.add_entity(get_tile_from_global(entity.global_position), entity)
	
func get_tile_from_global(global: Vector2) -> Vector2i:
	return local_to_map(to_local(global))


func get_global_from_tile(tile: Vector2i) -> Vector2:
	return to_global(map_to_local(tile))


func get_hovered_tile() -> Vector2i:
	return local_to_map(get_local_mouse_position())
