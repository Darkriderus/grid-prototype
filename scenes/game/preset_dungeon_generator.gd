class_name DungeonGenerator
extends Node

const LOOT_ASCII_SYMBOL := "L"
const MONSTER_ASCII_SYMBOL := "M"


@export_category("Map Dimensions")
@export var map_width: int = 100
@export var map_height: int = 100

@export_category("Rooms RNG")
@export var max_rooms: int = 30
@export var room_max_size: int = 10
@export var room_min_size: int = 6

@export_category("Entities RNG")

@export var item_chances = {
	0: {Entity.EntityKey.NOTHING: 25, Entity.EntityKey.HEALTH_POTION: 35, Entity.EntityKey.LIGHTNING_SCROLL: 10},
	2: {Entity.EntityKey.CONFUSION_SCROLL: 10},
	4: {Entity.EntityKey.LIGHTNING_SCROLL: 25, Entity.EntityKey.SWORD: 5},
	6: {Entity.EntityKey.FIREBALL_SCROLL: 25, Entity.EntityKey.CHAINMAIL: 15},
}
@export var enemy_chances = {
	0: {Entity.EntityKey.NOTHING: 50, Entity.EntityKey.ORC: 80, Entity.EntityKey.TROLL: 5},
	3: {Entity.EntityKey.TROLL: 15},
	5: {Entity.EntityKey.TROLL: 30},
	7: {Entity.EntityKey.TROLL: 60}
}

var _rng := RandomNumberGenerator.new()


func _get_max_value_for_floor(weighted_chances_by_floor: Array, current_floor: int) -> int:
	var current_value = 0
	
	for chance in weighted_chances_by_floor:
		if chance[0] > current_floor:
			break
		else:
			current_value = chance[1]
	
	return current_value


func _get_entities_at_random(weighted_chances_by_floor: Dictionary, number_of_entities: int, current_floor: int) -> Array[Entity.EntityKey]:
	var entity_weighted_chances = {}
	var chosen_entities: Array[Entity.EntityKey] = []
	
	for key in weighted_chances_by_floor:
		if key > current_floor:
			break
		else:
			for entity_name in weighted_chances_by_floor[key]:
				entity_weighted_chances[entity_name] = weighted_chances_by_floor[key][entity_name]
	
	for _i in number_of_entities:
		chosen_entities.append(_pick_weighted(entity_weighted_chances))
	
	return chosen_entities
	
	
func _pick_weighted(weighted_chances: Dictionary) -> Entity.EntityKey:
	var keys: Array[Entity.EntityKey] = []
	var cumulative_chances := []
	var sum: int = 0
	for key in weighted_chances:
		keys.append(key)
		var chance: int = weighted_chances[key]
		sum += chance
		cumulative_chances.append(sum)
	var random_chance: int = _rng.randi_range(0, sum - 1)
	var selection: Entity.EntityKey
	
	for i in cumulative_chances.size():
		if cumulative_chances[i] > random_chance:
			selection = keys[i]
			break
	
	return selection
	

func _ready() -> void:
	_rng.randomize()


func _set_tile(dungeon: MapData, x: int, y: int, tile_type: Tile.TileTypeKeys) -> void:
	var tile_position = Vector2i(x, y)
	var tile: Tile = dungeon.get_tile(tile_position)
	tile.set_tile_type(tile_type)


func generate_dungeon(player: Entity, current_floor: int) -> MapData:
	var dungeon := MapData.new(map_width, map_height, player)
	dungeon.current_floor = current_floor
	dungeon.entities.append(player)
	
	for key in Tile.TileTypeKeys.values():
		print(Tile.tile_types[key].ascii_char)
	
	var file = FileAccess.open("res://assets/dungeons/dungeon_1.txt", FileAccess.READ)

	var y := 0
	while not file.eof_reached():
		var line := file.get_line()
		
		if line.is_empty():
			y += 1
			continue

		for x in line.length():
			var coord := Vector2i(x,y)
			var ascii_char := line[x]
			var found := false
			for key in Tile.TileTypeKeys.values():
				if ascii_char == Tile.tile_types[key].ascii_char:
					_set_tile(dungeon, x, y, key)
					found = true
					if key == Tile.TileTypeKeys.UP_STAIRS:
						player.grid_position = coord
						player.map_data = dungeon
						
			## TODO: Change default if necessary
			if not found:
				_set_tile(dungeon, x, y, Tile.TileTypeKeys.FLOOR)
						
			if ascii_char == MONSTER_ASCII_SYMBOL:
				_set_entity(coord, enemy_chances, dungeon)
					
			if ascii_char == LOOT_ASCII_SYMBOL:
				_set_entity(coord, item_chances, dungeon)
		y += 1
#
	file.close()
	
	dungeon.setup_pathfinding()
	return dungeon
	
func _set_entity(coord: Vector2i, spawn_chances: Dictionary, dungeon: MapData):
	var entities: Array[Entity.EntityKey] = _get_entities_at_random(spawn_chances, 1, dungeon.current_floor)
	
	if entities.size() > 0:
		var entity_key_to_spawn = entities.pick_random()
		if entity_key_to_spawn == Entity.EntityKey.NOTHING:
			return
		var new_entity := Entity.new(dungeon, coord, entities.pick_random())
		dungeon.entities.append(new_entity)
	
