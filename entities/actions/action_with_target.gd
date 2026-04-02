class_name ActionWithTarget
extends Action

var target: Entity


func _init(_entity: Entity, _target: Entity) -> void:
	super._init(_entity)
	target = _target
