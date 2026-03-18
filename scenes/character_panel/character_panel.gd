class_name CharacterPanel
extends CanvasLayer

signal equipment_done

const ITEM_SCENE := preload("uid://bkfdapug4i13k")
var entity: Entity

@onready var title_label: Label = %TitleLabel

func _ready() -> void:
	hide()

func build(_entity: Entity) -> void:
	entity = _entity
	title_label.text = entity.get_entity_name()
	
	show()

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_back"):
		equipment_done.emit()
		queue_free()
