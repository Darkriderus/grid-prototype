class_name ItemComponentDefinition
extends Resource

@export_group("Item Infos")

@export_range(0, 100, 0.1) var weight: float = 0.0 # in kg
@export_range(1, 10, 1) var slots: int = 1
@export var stackable: bool = false
