class_name EquippableComponent
extends ItemComponent

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

const ArmorEquipmentTypes := [
	EquipmentType.HEAD,
	EquipmentType.BODY,
	EquipmentType.HANDS,
	EquipmentType.FEET
]

var equipment_type: EquipmentType
var protection: int
var dodge_chance: float
var two_handed: bool
var min_damage: int 
var max_damage: int 
var attack_range: int
var weight_carry_increase : float = 0.0
var volume_carry_increase : float = 0.0

func _init(definition: EquippableComponentDefinition) -> void:
	equipment_type = definition.equipment_type
	protection = definition.protection
	dodge_chance = definition.dodge_chance
	two_handed = definition.two_handed
	min_damage = definition.min_damage
	max_damage = definition.max_damage
	attack_range = definition.attack_range
	weight_carry_increase = definition.weight_carry_increase
	volume_carry_increase = definition.volume_carry_increase
	
	
	super._init(definition)
