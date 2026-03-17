class_name FighterComponent
extends Component

signal changed
#
#var max_hp: int
#var hp: int:
	#set(value):
		#hp = clampi(value, 0, max_hp)
		#hp_changed.emit(hp, max_hp)
		#if hp <= 0:
			#var die_silently := false
			#if not is_inside_tree():
				#die_silently = true
				#await ready
			#die(not die_silently)
#var base_defense: int
#var base_ranged_power: int
#var base_melee_power : int
#var defense: int: 
	#get:
		#return base_defense + get_defense_bonus()
#var melee_power: int: 
	#get:
		#return base_melee_power + get_melee_power_bonus()
#var ranged_power: int: 
	#get:
		#return base_ranged_power + get_ranged_power_bonus()
#func get_defense_bonus() -> int:
	#if entity.equipment_component:
		#return entity.equipment_component.get_defense_bonus()
	#return 0

# Static Stats
var base_strength: int 
var strength: int:
	get:
		return base_strength	
	
var base_agility: int 
var agility: int:
	get:
		return base_agility	

var base_perception: int 
var perception: int:
	get:
		return base_perception	

var base_vitality: int
var vitality: int:
	get:
		return base_vitality	
		
var base_willpower: int 
var willpower: int:
	get:
		return base_willpower	

# Dynamic Stats
var melee_damage_percentage: int:
	get:
		return 100 + (2*strength)
		
var ranged_damage_percentage: int:
	get:
		return 100 + (2*perception)
		
var accuracy: int:
	get:
		return 80 + (2*perception)
		
var max_health: int:
	get:
		return 100 + (5*vitality)
		
var dodge: int:
	get:
		return 5 + (1*agility)


# Changing stats
var health: int:
	set(value):
		health = clampi(value, 0, max_health)
		changed.emit()
		if health <= 0:
			var die_silently := false
			if not is_inside_tree():
				die_silently = true
				await ready
			die(not die_silently)


var death_texture: Texture
var death_color: Color


func _init(definition: FighterComponentDefinition) -> void:
	base_strength = definition.strength
	base_agility = definition.agility
	base_perception = definition.perception
	base_vitality = definition.vitality
	base_willpower = definition.willpower
	
	death_texture = definition.death_texture
	death_color = definition.death_color
	
func die(trigger_side_effects := true) -> void:
	var death_message: String
	var death_message_color: Color
	
	if get_map_data().player == entity:
		death_message = "You died!"
		death_message_color = GameColors.PLAYER_DIE
		SignalBus.player_died.emit()
	else:
		death_message = "%s is dead!" % entity.get_entity_name()
		death_message_color = GameColors.ENEMY_DIE
	
	if trigger_side_effects:
		MessageLog.send_message(death_message, death_message_color)
		get_map_data().player.level_component.add_xp(entity.level_component.xp_given)
	entity.texture = death_texture
	entity.modulate = death_color
	entity.ai_component.queue_free()
	entity.ai_component = null
	entity.entity_name = "Remains of %s" % entity.entity_name
	entity.blocks_movement = false
	entity.type = Entity.EntityType.CORPSE
	get_map_data().unregister_blocking_entity(entity)
	
	
func heal(amount: int) -> int:
	if health == max_health:
		return 0
	
	var new_health: int = health + amount
	
	if new_health > max_health:
		new_health = max_health
		
	var amount_recovered: int = new_health - health
	health = new_health
	return amount_recovered


func take_damage(amount: int) -> void:
	health -= amount
	
	
func get_save_data() -> Dictionary:
	return {
		"base_strength": base_strength,
		"base_agility": base_agility,
		"base_perception": base_perception,
		"base_vitality": base_vitality,
		"base_willpower": base_willpower,
		"health": health
	}


func restore(save_data: Dictionary) -> void:
	base_strength = save_data["base_strength"]
	base_agility = save_data["base_agility"]
	base_perception = save_data["base_perception"]
	base_vitality = save_data["base_vitality"]
	base_willpower = save_data["base_willpower"]
	health = save_data["health"]
