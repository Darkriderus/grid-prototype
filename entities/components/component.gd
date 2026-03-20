class_name Component
extends Node

# TODO: Manually set?! TO Check
@onready var entity: Entity = get_parent() as Entity


func get_map_data() -> MapData:
	return entity.map_data
