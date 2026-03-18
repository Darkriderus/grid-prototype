class_name FighterComponent
extends Component

signal changed

var rng = RandomNumberGenerator.new()

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
		
var dodge_chance: int:
	get:
		return 5 + (1*agility)

var min_melee_damage: int:
	get:
		var weapon_used = entity.equipment_component.get_item_from_slot(EquippableComponent.EquipmentType.MELEE_RIGHT_HAND)
		# TODO: add unarmed weapon to every fighter
		var base_weapon_damage = weapon_used.equippable_component.min_damage if weapon_used is Entity else 2
		return int(base_weapon_damage * melee_damage_percentage)
		
var max_melee_damage: int:
	get:
		var weapon_used = entity.equipment_component.get_item_from_slot(EquippableComponent.EquipmentType.MELEE_RIGHT_HAND)
		# TODO: add unarmed weapon to every fighter
		var base_weapon_damage = weapon_used.equippable_component.max_damage if weapon_used is Entity else 5
		return int(base_weapon_damage * melee_damage_percentage)
		
var protection: int:
	get:
		# TODO: Split by body part
		var protection_sum := 0
		for equipment in entity.equipment_component.slots.values():
			if equipment.equippable_component:
				protection_sum += equipment.equippable_component.protection
				
		return protection_sum

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
	
# TODO: fumble, critical

func melee_try_to_hit(_defender: Entity) -> Dictionary[String, Variant]:
	var to_hit_roll := roll()
	var has_hit := accuracy <= to_hit_roll
	return {
		"has_hit": has_hit,
		"to_hit_roll": to_hit_roll,
		"hit_threshold": accuracy
	}


# TODO: fumble, critical
func melee_damage(_defender: Entity) -> int:
	var damage_roll := roll(min_melee_damage, max_melee_damage)
	return damage_roll
	
func try_to_dodge(_attacker: Entity) -> Dictionary[String, Variant]:
	var to_dodge_roll := roll(0, 100)
	var has_dodged := dodge_chance <= to_dodge_roll
	return {
		"to_dodge_roll": to_dodge_roll,
		"has_dodged": has_dodged,
		"dodge_threshold": dodge_chance
	}
	
func heal(amount: int) -> int:
	if health == max_health:
		return 0
	
	var new_health: int = health + amount
	
	if new_health > max_health:
		new_health = max_health
		
	var amount_recovered: int = new_health - health
	health = new_health
	return amount_recovered


func take_damage(amount: int) -> int:
	var damage_given = clampi((amount - protection), 0, amount)
	health -= damage_given
	return damage_given
	
	
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

#TODO: move to other class / helper?
func roll(min_roll: int = 0, max_roll: int = 100) -> int:
	return rng.randi_range(min_roll, max_roll)
