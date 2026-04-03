class_name StatComponentDefinition
extends Resource

@export_category("Stats")
@export var strength: int = 0
@export var agility: int = 0
@export var perception: int = 0
@export var vitality: int = 0
@export var willpower: int = 0

@export_category("Visuals")
@export var death_texture: AtlasTexture = preload("uid://cikrfsq0axk2j")
@export var death_color: Color = Color.WHITE
