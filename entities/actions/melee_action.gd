class_name MeleeAction
extends ActionWithDirection


func perform() -> bool:
	var target: Entity = get_target_actor()
	if not target:
		if entity == get_map_data().player:
			MessageLog.send_message("Nothing to attack.", GameColors.IMPOSSIBLE)
		return false
		
	# step 0 - prepare stuff
	var attacker := entity
	var defender := target
	
	# step 1 - check if attacker hits defender
	var attack_result := attacker.fighter_component.melee_try_to_hit(defender)
	if attack_result["has_hit"] == false:
		MessageLog.send_message("%s misses %s (rolled %s, needed %s)" % [attacker.get_entity_name(), defender.get_entity_name(), attack_result["to_hit_roll"], attack_result["hit_threshold"]], Color.GREEN)
		entity.end_turn()
		return true
	
	# step 2 - check if defender dodges
	var dodge_result := defender.fighter_component.try_to_dodge(attacker)
	if dodge_result["has_dodged"] == true:
		MessageLog.send_message("%s dodges (rolled %s, needed %s)" % [defender.get_entity_name(), dodge_result["to_dodge_roll"], dodge_result["dodge_threshold"]], Color.BLUE)
		entity.end_turn()
		return true
		
	# step 3 - calculate damage
	var damage := attacker.fighter_component.melee_damage(defender)
	var damage_given := defender.fighter_component.take_damage(damage)
	if damage_given <= 0:
		MessageLog.send_message("%s hits %s, but deals no damage" % [attacker.get_entity_name(), defender.get_entity_name()], Color.RED)
		entity.end_turn()
		return true

	# step 4 - ???
	MessageLog.send_message("%s hits %s, dealing %s damage" % [attacker.get_entity_name(), defender.get_entity_name(), damage_given], Color.RED)
	entity.end_turn()
	return true
