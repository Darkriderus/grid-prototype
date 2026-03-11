class_name FighterComponentDefinition
extends Resource

@export_category("Stats")
@export var max_hp: int
@export var melee_power: int = 1
@export var ranged_power: int = 1
@export var defense: int = 0

@export_category("Visuals")
@export var death_texture: AtlasTexture = preload("uid://cikrfsq0axk2j")
@export var death_color: Color = Color.WHITE
