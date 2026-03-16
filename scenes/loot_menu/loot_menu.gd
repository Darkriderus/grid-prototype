class_name LootMenu
extends CanvasLayer

signal looting_done

const inventory_menu_item_scene := preload("uid://bkfdapug4i13k")

@onready var inventory_list: VBoxContainer = %InventoryList
@onready var loot_list: VBoxContainer = %LootList
@onready var title_label: Label = %TitleLabel


var player : Entity
var entity_to_loot : Entity


func button_pressed(item: Entity) -> void:
	if player.inventory_component.items.has(item):
		player.inventory_component.drop(item, true)
		entity_to_loot.inventory_component.items.append(item)
	else:
		entity_to_loot.inventory_component.drop(item, true)
		player.inventory_component.items.append(item)

	build("Lootylooty", player, entity_to_loot)

func _ready() -> void:
	hide()



func _register_item(index: int, item: Entity, is_equipped: bool, entity: Entity) -> void:
	var item_button: Button = inventory_menu_item_scene.instantiate()
	item_button.text = "%s" % [item.get_entity_name()]
	if is_equipped:
		item_button.text = "(E) " + item_button.text
	
	if entity == player:
		inventory_list.add_child(item_button)
	else:
		loot_list.add_child(item_button)
		
	
	item_button.pressed.connect(button_pressed.bind(item))



func build(title_text: String, player: Entity, entity_to_loot: Entity) -> void:
	self.player = player
	self.entity_to_loot = entity_to_loot
	
	var equipment: EquipmentComponent = player.equipment_component
	title_label.text = title_text
	for i in player.inventory_component.items.size():
		var item: Entity = player.inventory_component.items[i]
		var is_equipped: bool = equipment.is_item_equipped(item)
		_register_item(i, item, is_equipped, player)
	inventory_list.get_child(0).grab_focus()
	
	for i in entity_to_loot.inventory_component.items.size():
		var item: Entity = entity_to_loot.inventory_component.items[i]
		_register_item(i, item, false, entity_to_loot)
	#inventory_list.get_child(0).grab_focus()
	show()
	
func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_back"):
		looting_done.emit()
		queue_free()
