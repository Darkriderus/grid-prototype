class_name SlotRow
extends HBoxContainer

signal equipment_change_requested

@onready var slot_name: Label = $SlotName
@onready var equipment_button: Button = $EquipmentButton


func build(entity: Entity, slot: EquippableComponent.EquipmentType):
	# TODO: find better way to have a nice string
	slot_name.text = EquippableComponent.EquipmentType.keys()[slot].replace("_", " ")
	var equipped_item = entity.equipment_component.get_item_from_slot(slot)
	equipment_button.text = equipped_item.entity_name if equipped_item else "Empty"
	equipment_button.icon = equipped_item.texture if equipped_item else null
	equipment_button.pressed.connect(func(): equipment_change_requested.emit())
	
