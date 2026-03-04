class_name FighterComponentDefinition
extends Resource

@export_category("Stats")
@export var max_hp: int
@export var power: int
@export var defense: int

@export_category("Visuals")
@export var death_texture: AtlasTexture = preload("uid://cikrfsq0axk2j")
@export var death_color: Color = Color.WHITE
