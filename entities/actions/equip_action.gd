class_name EquipAction
extends Action

var item: Entity


func _init(_entity: Entity, _item: Entity) -> void:
	super._init(_entity)
	item = _item


func perform() -> bool:
	entity.equipment_component.toggle_equip(item)
	
	return true
