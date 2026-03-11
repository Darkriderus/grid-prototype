class_name SelectAction
extends ActionWithDirection

func perform() -> bool:
	# TODO: Logic to dynamically do stuff depending on what i select/click	
	var diff: Vector2i = offset - entity.grid_position
	var distance: int = max(abs(diff.x), abs(diff.y))
	if distance <= 1:
		return BumpAction.new(entity, diff.x, diff.y).perform()
	else:
		var path := entity.map_data.pathfinder.get_point_path(entity.grid_position, offset)
		if path.size() <= 1:
			return false
		diff = Vector2i(path[1]) - entity.grid_position
		return BumpAction.new(entity, diff.x, diff.y).perform()
	
