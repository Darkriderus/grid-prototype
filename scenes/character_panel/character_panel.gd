class_name CharacterPanel
extends CanvasLayer

signal equipment_done

const ITEM_SCENE := preload("uid://bkfdapug4i13k")
var entity: Entity

@onready var title_label: Label = %TitleLabel
@onready var slot_list: VBoxContainer = %SlotList

func _ready() -> void:
	hide()

func build(_entity: Entity) -> void:
	entity = _entity
	title_label.text = entity.get_entity_name()
	
	# TODO: Remove this filth
	for slot in EquippableComponent.EquipmentType.keys():
		var row = HBoxContainer.new()
		slot_list.add_child(row)
		var label1 = Label.new()
		label1.text = slot
		row.add_child(label1)
		
		var label2 = Label.new()
		var equipped_item = entity.equipment_component.get_item_from_slot(EquippableComponent.EquipmentType[slot])
		label2.text = equipped_item.entity_name if equipped_item else "Empty"
		row.add_child(label2)
	
	show()

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_back"):
		equipment_done.emit()
		queue_free()
