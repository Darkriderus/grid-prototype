class_name InventoryMenu
extends CanvasLayer

signal item_selected(item)

const inventory_menu_item_scene := preload("uid://bkfdapug4i13k")

@onready var inventory_list: VBoxContainer = %InventoryList
@onready var title_label: Label = %TitleLabel


func _ready() -> void:
	hide()


func button_pressed(item: Entity = null) -> void:
	item_selected.emit(item)
	queue_free()
	
	
func _register_item(_index: int, _item: Entity, _amount: int = 1, _is_equipped: bool = false) -> void:
	var item_button: Button = inventory_menu_item_scene.instantiate()
	var shortcut_char: String = String.chr("a".unicode_at(0) + _index)
	
	item_button.text = "( %s ) %s x %s" % [shortcut_char, _amount, _item.get_item_name()]
	if _is_equipped:
		item_button.text = "(E) " + item_button.text
		
	var shortcut_event := InputEventKey.new()
	shortcut_event.keycode = KEY_A + _index
	item_button.shortcut = Shortcut.new()
	item_button.shortcut.events = [shortcut_event]
	
	item_button.pressed.connect(button_pressed.bind(_item))
	inventory_list.add_child(item_button)


func build(title_text: String, inventory: InventoryComponent, filter: Callable = (func (): return true)) -> void:
	if inventory.items.is_empty():
		button_pressed.call_deferred()
		MessageLog.send_message("No items in inventory.", GameColors.IMPOSSIBLE)
		return
		
	var equipment: EquipmentComponent = inventory.entity.equipment_component
	title_label.text = title_text
	
	var items := inventory.items
	items = items.filter(filter)
	
	if items.is_empty():
		button_pressed.call_deferred()
		MessageLog.send_message("No items in inventory.", GameColors.IMPOSSIBLE)
		return
	
	
	var button_items: Dictionary[Entity, int] = {}
	var key_to_entity: Dictionary = {} 

	# 1. Group and count items efficiently
	for item : Entity in items:
		var k = item.key
		if not key_to_entity.has(k) or not item.item_component.stackable:
			key_to_entity[k] = item
			button_items[item] = 0
		
		var actual_entity = key_to_entity[k]
		button_items[actual_entity] += 1

	# 2. Register items
	var index := 0
	for item in button_items:
		var count = button_items[item]
		var is_equipped: bool = equipment.is_item_equipped(item) if equipment else false
		_register_item(index, item, count, is_equipped)
		index += 1
		show()
	
func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_back"):
		item_selected.emit(null)
		queue_free()
