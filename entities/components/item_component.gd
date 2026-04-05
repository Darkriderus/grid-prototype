class_name ItemComponent
extends Component

var weight: float
var slots: int = 0
var stackable: bool = false

func _init(definition: ItemComponentDefinition) -> void:
	weight = definition.weight
	slots = definition.slots
	stackable = definition.stackable
