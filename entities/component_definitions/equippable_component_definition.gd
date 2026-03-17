class_name EquippableComponentDefinition
extends ItemComponentDefinition

@export_category("Common")
@export var equipment_type: EquippableComponent.EquipmentType

@export_category("Armor")
@export var protection: int = 0
@export var dodge_chance: float = 0.0

@export_category("Weapons")
@export var two_handed: bool = false
@export var min_damage: int = 0
@export var max_damage: int = 0
@export var attack_range: int = 1
