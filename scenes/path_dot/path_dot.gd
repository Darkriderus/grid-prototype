class_name PathDot
extends Node2D

var map_data: MapData
@export var color : Color = Color.WHITE
@export var is_last_dot : bool = false

@onready var dot: Sprite2D = $Dot
@onready var last_dot: Sprite2D = $LastDot


func _ready() -> void:
	modulate = color
	last_dot.visible = is_last_dot
	dot.visible = not is_last_dot
	# hide()
	
	
	set_physics_process(false)
	
#func _physics_process(delta: float) -> void:
	#pass
