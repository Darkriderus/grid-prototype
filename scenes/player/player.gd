class_name Player
extends CharacterBody2D

var tween: Tween

@onready var sprite: Sprite2D = $Sprite

@onready var up: RayCast2D = $Up
@onready var up_right: RayCast2D = $UpRight
@onready var right: RayCast2D = $Right
@onready var down_right: RayCast2D = $DownRight
@onready var down: RayCast2D = $Down
@onready var down_left: RayCast2D = $DownLeft
@onready var left: RayCast2D = $Left
@onready var up_left: RayCast2D = $UpLeft

func _ready() -> void:
	if not self.is_in_group("characters"):
		self.add_to_group("characters")
	
	TurnManager.add_character(self)
	
	Signals.turn_started.connect(_on_turn_started)

func _on_turn_started(character: CharacterBody2D):
	if character != self:
		return
		
	print("My turn! ", self.name) 

func _physics_process(_delta: float) -> void:
	if TurnManager.current_turn_character != self:
		return
		
	if (not tween or not tween.is_running()):
		if Input.is_action_pressed("move_up") and not up.is_colliding():
			_move(Direction.UP)
		
		if Input.is_action_pressed("move_up_right") and (not up_right.is_colliding()):
			_move(Direction.UP_RIGHT)
			
		if Input.is_action_pressed("move_right") and not right.is_colliding():
			_move(Direction.RIGHT)
			
		if Input.is_action_pressed("move_down_right") and (not down_right.is_colliding()):
			_move(Direction.DOWN_RIGHT)
			
		if Input.is_action_pressed("move_down") and not down.is_colliding():
			_move(Direction.DOWN)
			
		if Input.is_action_pressed("move_down_left") and (not down_left.is_colliding()):
			_move(Direction.DOWN_LEFT)
			
		if Input.is_action_pressed("move_left") and not left.is_colliding():
			_move(Direction.LEFT)

		if Input.is_action_pressed("move_up_left") and (not up_left.is_colliding()):
			_move(Direction.UP_LEFT)

func _move(direction: Vector2) -> void:
	global_position += direction * Constants.TILE_SIZE
	sprite.global_position -= direction * Constants.TILE_SIZE
	
	if tween:
		tween.kill()
	
	tween = create_tween()
	tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.tween_property(sprite, "global_position", global_position, Constants.MOVE_SPEED).set_trans(Tween.TRANS_SINE)
	tween.tween_callback(_turn_end)

func _turn_end():
	print("Turn ended: ", self)
	Signals.turn_ended.emit(self)
	
