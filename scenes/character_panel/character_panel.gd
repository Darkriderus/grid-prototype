class_name CharacterPanel
extends CanvasLayer

signal equipment_done

const SLOT_ROW_SCENE := preload("uid://dogieybrlqp7h")
const INVENTORY_ITEM_SCENE = preload("uid://bkfdapug4i13k")

var entity: Entity

@onready var title_label: Label = %TitleLabel
@onready var slot_list: VBoxContainer = %SlotList
@onready var inventory_display: VBoxContainer = %FilteredInventoryDisplay

func _ready() -> void:
	hide()

func build(_entity: Entity, rebuild_inventory: bool = true) -> void:
	# TODO: Rebuild this after i decide the UI
	entity = _entity
	title_label.text = entity.get_entity_name()
	
	for child in slot_list.get_children():
		child.queue_free()
	
	for slot in EquippableComponent.EquipmentType.values():
		var row : SlotRow = SLOT_ROW_SCENE.instantiate()
		slot_list.add_child(row)
		row.build(entity, slot)	
		
		row.equipment_change_requested.connect(_change_equipment_button_pressed.bind(slot))
	
	if(rebuild_inventory):
		for item in entity.inventory_component.items:
			if item.is_equippable():
				var item_button : Button = INVENTORY_ITEM_SCENE.instantiate()
				item_button.icon = item.texture
				item_button.text = item.entity_name
				item_button.name = "item-%s" % entity.inventory_component.items.find(item)
				item_button.pressed.connect(_on_item_button_pressed.bind(item))
				inventory_display.add_child(item_button)
	inventory_display.hide()
	show()

func _on_item_button_pressed(item: Entity):
	entity.equipment_component.toggle_equip(item)
	inventory_display.hide()
	
	build(entity, false)


func _change_equipment_button_pressed(slot: EquippableComponent.EquipmentType):		
	
	var has_items_for_slot := false
	for item in entity.inventory_component.items:
		if item.is_equippable():
			var item_button = inventory_display.get_node("item-%s" % entity.inventory_component.items.find(item))
			if item.equippable_component.equipment_type == slot:
				has_items_for_slot = true
				item_button.show()
			else:
				item_button.hide()		
	
	inventory_display.visible = has_items_for_slot

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_back"):
		equipment_done.emit()
		queue_free()
