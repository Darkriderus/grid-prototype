class_name PlayerCharacter
extends Character

var is_moving := false

func _ready() -> void:
	pass
	
func _physics_process(_delta: float) -> void:
	if is_moving:
		return
		
	var input_dir := Vector2.ZERO
	if Input.is_action_just_pressed("ui_down"):
		input_dir = Vector2(0, 1)
	if Input.is_action_just_pressed("ui_up"):
		input_dir = Vector2(0, -1)
	if Input.is_action_just_pressed("ui_right"):
		input_dir = Vector2(1, 0)
	if Input.is_action_just_pressed("ui_left"):
		input_dir = Vector2(-1, 0)
		
	if input_dir:
		_move(input_dir)	

	move_and_slide()

func _move(input_dir: Vector2) -> void:
	if input_dir and not is_moving:
		var move_to_tile = grid_logic.get_entity_tile(self) + Vector2i(input_dir)
		if grid_logic.is_tile_occupied(move_to_tile):
			print("ATTACK!")
		else:
			is_moving = true
			var tween = create_tween()
			tween.tween_property(self, "position", position + input_dir * GridLogic.TILE_SIZE, GridLogic.ANIMATION_SPEED)
			tween.tween_callback(_on_move_end)

func _on_move_end() -> void:
	var grid_tile := grid_logic.get_tile_from_global(global_position)
	grid_logic.move_entity(self, grid_tile)
	is_moving = false
