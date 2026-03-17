class_name FighterComponentDefinition
extends Resource

@export_category("Stats")
@export var strength: int = 10
@export var agility: int = 10
@export var perception: int = 10
@export var vitality: int = 10
@export var willpower: int = 10

@export_category("Visuals")
@export var death_texture: AtlasTexture = preload("uid://cikrfsq0axk2j")
@export var death_color: Color = Color.WHITE
