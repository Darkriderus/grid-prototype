class_name EquippableComponent
extends Component

enum EquipmentType { MELEE_WEAPON, ARMOR, RANGED_WEAPON }

var equipment_type: EquipmentType
var ranged_power_bonus: int = 0
var melee_power_bonus: int = 0
var defense_bonus: int


func _init(definition: EquippableComponentDefinition) -> void:
	equipment_type = definition.equipment_type
	ranged_power_bonus = definition.ranged_power_bonus
	melee_power_bonus = definition.melee_power_bonus
	defense_bonus = definition.defense_bonus
