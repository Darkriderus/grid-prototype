class_name ItemComponent
extends Component

var weight: float
var volume: float = 0.0
var stackable: bool = false

func _init(definition: ItemComponentDefinition) -> void:
	weight = definition.weight
	volume = definition.volume
	stackable = definition.stackable
