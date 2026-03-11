class_name Map
extends Node2D

signal dungeon_floor_changed(floor)

var map_data: MapData
var current_mouse_grid_coord : Vector2i = Vector2i.ZERO

@onready var tiles: Node2D = $Tiles
@onready var entities: Node2D = $Entities
@onready var dungeon_generator: DungeonGenerator = $DungeonGenerator
@onready var field_of_view: FieldOfView = $FieldOfView
@onready var path_dots: Node2D = $PathDots

const path_dot_scene := preload("uid://dwjhxap5vcy60")

func _ready() -> void:
	SignalBus.player_descended.connect(next_floor)


func _physics_process(delta: float) -> void:
	_draw_path_to_mouse()


func next_floor() -> void:
	var player: Entity = map_data.player
	entities.remove_child(player)
	for entity in entities.get_children():
		entity.queue_free()
	for tile in tiles.get_children():
		tile.queue_free()
	generate(player, map_data.current_floor + 1)
	player.get_node("Camera2D").make_current()
	field_of_view.reset_fov()
	update_fov(player.grid_position)


func generate(player: Entity, current_floor: int = 1) -> void:
	map_data = dungeon_generator.generate_dungeon(player, current_floor)
	if not map_data.entity_placed.is_connected(entities.add_child):
		map_data.entity_placed.connect(entities.add_child)
	_place_tiles()
	_place_entities()
	dungeon_floor_changed.emit(current_floor)
	
	
func update_fov(player_position: Vector2i) -> void:
	field_of_view.update_fov(map_data, player_position, 8)
	
	for entity in map_data.entities:
		entity.visible = map_data.get_tile(entity.grid_position).is_in_view


func _draw_path_to_mouse():
	var mouse_grid_cord: Vector2i = Grid.world_to_grid(Vector2i(get_global_mouse_position()))
	if mouse_grid_cord != current_mouse_grid_coord:
		current_mouse_grid_coord = mouse_grid_cord
		var path = map_data.pathfinder.get_point_path(map_data.player.grid_position, current_mouse_grid_coord)

		for dot in path_dots.get_children():
			dot.queue_free()
		
		if path.size() > 1:
			path.remove_at(0)
			
			for step in path:
				var dot = path_dot_scene.instantiate()
				dot.position = Grid.grid_to_world(step)
				dot.is_last_dot = path[-1] == step			
				path_dots.add_child(dot)


func _place_entities() -> void:
	for entity in map_data.entities:
		entities.add_child(entity)


func _place_tiles() -> void:
	for tile in map_data.tiles:
		tiles.add_child(tile)
		
	
func load_game(player: Entity) -> bool:
	map_data = MapData.new(0, 0, player)
	map_data.entity_placed.connect(entities.add_child)
	if not map_data.load_game():
		return false
	_place_tiles()
	_place_entities()
	dungeon_floor_changed.emit(map_data.current_floor)
	return true
