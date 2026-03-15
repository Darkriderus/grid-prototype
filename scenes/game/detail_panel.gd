class_name DetailPanel
extends PanelContainer

@onready var title_label: Label = %TitleLabel
@onready var detail_hp_display: MarginContainer = %DetailHpDisplay
@onready var detail_hp_bar: ProgressBar = %DetailHpBar
@onready var detail_hp_label: Label = %DetailHpLabel

@onready var detail_stats_display: HBoxContainer = %DetailStatsDisplay
@onready var detail_melee_power_label: Label = %DetailMeleePowerLabel
@onready var detail_ranged_power_label: Label = %DetailRangedPowerLabel
@onready var defense_defense_label: Label = %DefenseDefenseLabel

func _ready() -> void:
	hide()
	SignalBus.entities_focussed.connect(_on_entities_focussed)
	

func _on_entities_focussed(entities_list: Array[Entity]):
	if entities_list.size() > 0:
		show()
		# TODO: Loop?
		var entity_to_show := entities_list[0]
		title_label.text = entities_list[0].entity_name
		
		detail_hp_display.visible = entity_to_show.fighter_component != null
		detail_stats_display.visible = entity_to_show.fighter_component != null
		if entity_to_show.fighter_component:
			detail_hp_bar.max_value = entity_to_show.fighter_component.max_hp
			detail_hp_bar.value = entity_to_show.fighter_component.hp
			detail_hp_label.text = "HP: %d/%d" % [entity_to_show.fighter_component.hp, entity_to_show.fighter_component.max_hp]
			
			detail_melee_power_label.text = "MLD: %d" % entity_to_show.fighter_component.melee_power
			detail_ranged_power_label.text = "RGD: %d" % entity_to_show.fighter_component.ranged_power
			defense_defense_label.text = "DEF: %d" % entity_to_show.fighter_component.defense
			
		
	else:
		hide()
