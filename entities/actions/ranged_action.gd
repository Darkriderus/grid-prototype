class_name RangedAction
extends ActionWithDirection


func perform() -> bool:
	if not entity.equipment_component.get_item_from_slot(EquippableComponent.EquipmentType.RANGED):
		if entity == get_map_data().player:
			MessageLog.send_message("No ranged weapon equipped.", GameColors.IMPOSSIBLE)
		return false
	
	# TODO: Change to specific ammo
	if not entity.inventory_component.has_item_type(Entity.EntityKey.ARROWS):
		if entity == get_map_data().player:
			MessageLog.send_message("No ammo left.", GameColors.IMPOSSIBLE)
		return false
	
	var ranged_weapon : Entity = entity.equipment_component.get_item_from_slot(EquippableComponent.EquipmentType.RANGED)
		
	# TODO: needs rewrite if we add buff-items
	var target: Entity = get_target_actor()
	if not target:
		if entity == get_map_data().player:
			MessageLog.send_message("Nothing to attack.", GameColors.IMPOSSIBLE)
		return false
	#
	
	if entity.distance(target.grid_position) > ranged_weapon.equippable_component.attack_range:
		if entity == get_map_data().player:
			MessageLog.send_message("Target too far.", GameColors.IMPOSSIBLE)
		return false
	
	
	var arrow_entity = entity.inventory_component.get_items_by_type(Entity.EntityKey.ARROWS)[0]
	entity.inventory_component.items.erase(arrow_entity)
	
	var damage: int = entity.fighter_component.ranged_power - target.fighter_component.defense
	var attack_color: Color
	if entity == get_map_data().player:
		attack_color = GameColors.PLAYER_ATTACK
	else:
		attack_color = GameColors.ENEMY_ATTACK
	var attack_description: String = "%s shoots %s" % [entity.get_entity_name(), target.get_entity_name()]
	if damage > 0:
		attack_description += " for %d hit points." % damage
		MessageLog.send_message(attack_description, attack_color)
		target.fighter_component.hp -= damage
	else:
		attack_description += " but does no damage."
		MessageLog.send_message(attack_description, attack_color)
	return true
