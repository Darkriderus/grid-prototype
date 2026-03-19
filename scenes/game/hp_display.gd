extends MarginContainer

@onready var hp_bar: ProgressBar = %HpBar
@onready var hp_label: Label = %HpLabel

func initialize(player: Entity) -> void:
	if not is_inside_tree():
		await ready
	player.fighter_component.hp_changed.connect(player_hp_changed)
	var player_hp: int = player.fighter_component.health
	var player_max_hp: int = player.fighter_component.max_health
	player_hp_changed(player_hp, player_max_hp)


func player_hp_changed(max_health: int, health: int) -> void:
	hp_bar.max_value = max_health
	hp_bar.value = health
	hp_label.text = "HP: %d/%d" % [hp, max_hp]
