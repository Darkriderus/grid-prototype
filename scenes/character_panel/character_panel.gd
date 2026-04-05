class_name CharacterPanel
extends CanvasLayer

signal equipment_done

const SLOT_ROW_SCENE := preload("uid://dogieybrlqp7h")
const INVENTORY_ITEM_SCENE = preload("uid://bkfdapug4i13k")

var entity: Entity

@onready var title_label: Label = %TitleLabel
@onready var slot_list: VBoxContainer = %SlotList
@onready var inventory_display: VBoxContainer = %FilteredInventoryDisplay
@onready var equipment_display: VBoxContainer = %EquipmentDisplay
@onready var weight_value: Label = %WeightValue
@onready var carry_slot_value: Label = %VolumeValue


@onready var strength_value: Label = %StrengthValue
@onready var agility_value: Label = %AgilityValue
@onready var vitality_value: Label = %VitalityValue
@onready var perception_value: Label = %PerceptionValue
@onready var willpower_value: Label = %WillpowerValue

@onready var health_value: Label = %HealthValue
@onready var protection_value: Label = %ProtectionValue
@onready var accuracy_value: Label = %AccuracyValue
@onready var melee_damage_value: Label = %MeleeDamageValue
@onready var melee_damage_percentage_value: Label = %MeleeDamagePercentageValue
@onready var ranged_damage_value: Label = %RangedDamageValue
@onready var ranged_damage_percentage_value: Label = %RangedDamagePercentageValue
@onready var dodge_chance_value: Label = %DodgeChanceValue
@onready var ranged_attack_range: Label = %RangedAttackRange

func _ready() -> void:
	hide()

func build(_entity: Entity, rebuild_inventory: bool = true) -> void:
	# TODO: Rebuild this after i decide the UI
	entity = _entity
	if not entity.changed.is_connected(_refresh_stats):
		entity.changed.connect(_refresh_stats)
	title_label.text = entity.get_entity_name()
	
	_refresh_stats()
	
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
	equipment_display.show()
	show()

func _on_item_button_pressed(item: Entity):
	entity.equipment_component.toggle_equip(item)
	inventory_display.hide()
	
	build(entity, false)

func _refresh_stats():
	var stats := entity.stat_component
	var inventory := entity.inventory_component
	
	weight_value.text = "%s / %s kg" % [inventory.current_weight, inventory.weight_limit]
	carry_slot_value.text = "%s / %s slots" % [inventory.current_carry_slots, inventory.carry_slot_limit]


	strength_value.text = "%s" % stats.strength
	agility_value.text = "%s" % stats.agility
	vitality_value.text = "%s" % stats.vitality
	perception_value.text = "%s" % stats.perception
	willpower_value.text = "%s" % stats.willpower
	
	health_value.text = "%s / %s" % [stats.health, stats.max_health]
	protection_value.text = "%s" % stats.protection
	accuracy_value.text = "%s %%" % stats.accuracy
	melee_damage_value.text = "%s - %s" % [stats.min_melee_damage, stats.max_melee_damage]
	melee_damage_percentage_value.text = "%s %%" % stats.melee_damage_percentage
	ranged_damage_value.text = "%s - %s" % [stats.min_ranged_damage, stats.max_ranged_damage]
	ranged_attack_range.text = "%s" % stats.ranged_attack_range
	ranged_damage_percentage_value.text = "%s %%" % stats.ranged_damage_percentage
	dodge_chance_value.text = "%s %%" % stats.dodge_chance
	

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
	
	equipment_display.visible = not has_items_for_slot
	inventory_display.visible = has_items_for_slot

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_back"):
		equipment_done.emit()
		queue_free()
