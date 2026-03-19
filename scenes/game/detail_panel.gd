class_name DetailPanel
extends CanvasLayer

@onready var title_label: Label = %TitleLabel
@onready var detail_hp_display: MarginContainer = %DetailHpDisplay
@onready var detail_hp_bar: ProgressBar = %DetailHpBar
@onready var detail_hp_label: Label = %DetailHpLabel


func _ready() -> void:
	hide()
	SignalBus.entities_focussed.connect(_on_entities_focussed)
	

func _on_entities_focussed(entities_list: Array[Entity]):
	if entities_list.size() > 0:
		show()
		var entity_to_show := entities_list[0]
		title_label.text = entities_list[0].get_entity_name()
		
		detail_hp_display.visible = entity_to_show.fighter_component != null
		if entity_to_show.fighter_component:
			detail_hp_bar.max_value = entity_to_show.fighter_component.max_health
			detail_hp_bar.value = entity_to_show.fighter_component.health
			detail_hp_label.text = "HP: %d/%d" % [entity_to_show.fighter_component.health, entity_to_show.fighter_component.max_health]	
	else:
		hide()
