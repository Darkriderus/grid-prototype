class_name Player
extends Character

@onready var up: RayCast2D = $Up
@onready var up_right: RayCast2D = $UpRight
@onready var right: RayCast2D = $Right
@onready var down_right: RayCast2D = $DownRight
@onready var down: RayCast2D = $Down
@onready var down_left: RayCast2D = $DownLeft
@onready var left: RayCast2D = $Left
@onready var up_left: RayCast2D = $UpLeft


func _ready() -> void:
	super._ready()
	if not self.is_in_group("player"):
		self.add_to_group("player")

func _on_turn_started(character: CharacterBody2D):
	if character != self:
		return
		
	print("Turn started! ", name) 

func _physics_process(_delta: float) -> void:
	if TurnManager.current_turn_character != self:
		return
		
	if (not tween or not tween.is_running()):
		if Input.is_action_pressed("move_up") and not up.is_colliding():
			move(Direction.UP)
		
		if Input.is_action_pressed("move_up_right") and (not up_right.is_colliding()):
			move(Direction.UP_RIGHT)
			
		if Input.is_action_pressed("move_right") and not right.is_colliding():
			move(Direction.RIGHT)
			
		if Input.is_action_pressed("move_down_right") and (not down_right.is_colliding()):
			move(Direction.DOWN_RIGHT)
			
		if Input.is_action_pressed("move_down") and not down.is_colliding():
			move(Direction.DOWN)
			
		if Input.is_action_pressed("move_down_left") and (not down_left.is_colliding()):
			move(Direction.DOWN_LEFT)
			
		if Input.is_action_pressed("move_left") and not left.is_colliding():
			move(Direction.LEFT)

		if Input.is_action_pressed("move_up_left") and (not up_left.is_colliding()):
			move(Direction.UP_LEFT)

func move(direction: Vector2) -> void:
	super.move(direction)

func _turn_end():
	super._turn_end()
	TurnManager.end_turn(self)
