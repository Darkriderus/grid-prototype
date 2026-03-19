class_name InventoryComponentDefinition
extends Resource

# TODO: TO REMOVE
@export var capacity: int = 0

@export_range(0, 100, 0.1) var weight_limit: float = 30.0
@export_range(0, 100, 0.1) var volume_limit: float = 10.0
@export var delete_if_empty: bool = false
