class_name EquippableComponentDefinition
extends ItemComponentDefinition

@export_group("Equippable Infos")
@export_subgroup("Common")
@export var equipment_type: EquippableComponent.EquipmentType

@export_subgroup("Armor")
@export var protection: int = 0
@export var dodge_chance: float = 0.0

@export_subgroup("Weapons")
@export var two_handed: bool = false
@export var min_damage: int = 0
@export var max_damage: int = 0
@export var attack_range: int = 1

@export_subgroup("Backpack")
@export var weight_carry_increase : float = 0.0
@export var carry_slot_increase : int = 0
