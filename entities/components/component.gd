class_name Component
extends Node

var entity: Entity

func set_owner_entity(_entity: Entity) -> void:
	entity = _entity

func get_map_data() -> MapData:
	return entity.map_data
