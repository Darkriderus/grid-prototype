class_name ItemComponentDefinition
extends Resource

@export_group("Item Infos")

@export_range(0, 100, 0.1) var weight: float = 0.0 # in kg
@export_range(0, 100, 0.1) var volume: float = 0.0 # in liter / 10cm x 10cm x 10cm
@export var stackable: bool = false
