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
	
	
func _register_item(_index: int, _item: Entity, _is_equipped: bool) -> void:
	var item_button: Button = inventory_menu_item_scene.instantiate()
	var shortcut_char: String = String.chr("a".unicode_at(0) + _index)
	
	item_button.text = "( %s ) %s" % [shortcut_char, _item.get_entity_name()]
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
	
	var items = inventory.items
	items = items.filter(filter)
	for i in items.size():
		var item: Entity = items[i]
		var is_equipped: bool = equipment.is_item_equipped(item) if equipment else false
		_register_item(i, item, is_equipped)
	show()
	
func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_back"):
		item_selected.emit(null)
		queue_free()
