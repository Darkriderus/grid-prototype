class_name LootMenu
extends CanvasLayer

signal looting_done

const inventory_menu_item_scene := preload("uid://bkfdapug4i13k")

@onready var inventory_list: VBoxContainer = %InventoryList
@onready var loot_list: VBoxContainer = %LootList
@onready var title_label: Label = %TitleLabel


var player : Entity
var entity_to_loot : Entity


func button_pressed(item: Entity, button: Button) -> void:
	if player.inventory_component.items.has(item):
		if item.is_equippable() and player.equipment_component.get_item_from_slot(item.equippable_component.equipment_type) == item:
			player.equipment_component.toggle_equip(item, true)
		player.inventory_component.items.erase(item)
		entity_to_loot.inventory_component.items.append(item)
		button.reparent(loot_list)
		loot_list.get_child(-1).grab_focus()
	else:
		entity_to_loot.inventory_component.items.erase(item)
		player.inventory_component.items.append(item)
		button.reparent(inventory_list)
		inventory_list.get_child(-1).grab_focus()
	
	button.text = "%s" % [item.get_entity_name()]
	

func _ready() -> void:
	hide()


func _register_item(_index: int, _item: Entity, _is_equipped: bool, _entity: Entity) -> void:
	var item_button: Button = inventory_menu_item_scene.instantiate()
	item_button.text = "%s" % [_item.get_entity_name()]
	item_button.icon = _item.texture
	if _is_equipped:
		item_button.text = "(E) " + item_button.text
	
	if _entity == player:
		inventory_list.add_child(item_button)
	else:
		loot_list.add_child(item_button)
		
	
	item_button.pressed.connect(button_pressed.bind(_item, item_button))



func build(_title_text: String, _player: Entity, _entity_to_loot: Entity) -> void:
	player = _player
	entity_to_loot = _entity_to_loot
	
	var equipment: EquipmentComponent = player.equipment_component
	title_label.text = _title_text
	for i in player.inventory_component.items.size():
		var item: Entity = player.inventory_component.items[i]
		var is_equipped: bool = equipment.is_item_equipped(item)
		_register_item(i, item, is_equipped, player)
	if inventory_list.get_child_count() > 0:
		inventory_list.get_child(0).grab_focus()
	
	for i in entity_to_loot.inventory_component.items.size():
		var item: Entity = entity_to_loot.inventory_component.items[i]
		_register_item(i, item, false, entity_to_loot)
	if inventory_list.get_child_count() == 0 and loot_list.get_child_count() > 0:
		loot_list.get_child(0).grab_focus()
	show()
	
func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_back"):
		looting_done.emit()
		queue_free()
