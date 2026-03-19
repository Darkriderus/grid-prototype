class_name EquippableComponent
extends Component

enum EquipmentType { 
	HEAD,
	BODY,
	HANDS,
	FEET,
	RIGHT_HAND,
	LEFT_HAND,
	RANGED,
	BACKPACK,
}

var equipment_type: EquipmentType
var protection: int
var dodge_chance: float
var two_handed: bool
var min_damage: int 
var max_damage: int 
var attack_range: int


func _init(definition: EquippableComponentDefinition) -> void:
	equipment_type = definition.equipment_type
	protection = definition.protection
	dodge_chance = definition.dodge_chance
	two_handed = definition.two_handed
	min_damage = definition.min_damage
	max_damage = definition.max_damage
	attack_range = definition.attack_range
