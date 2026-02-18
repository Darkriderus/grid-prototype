extends CharacterBody2D

const TILE_SIZE: Vector2 = Vector2(32, 32)
var tween: Tween

@onready var up: RayCast2D = $Up
@onready var down: RayCast2D = $Down
@onready var left: RayCast2D = $Left
@onready var right: RayCast2D = $Right
@onready var sprite: Sprite2D = $Sprite

func _physics_process(delta: float) -> void:
	if !tween or !tween.is_running():
		if Input.is_action_pressed("ui_up") and !up.is_colliding():
			_move(Vector2.UP)
		if Input.is_action_pressed("ui_down") and !down.is_colliding():
			_move(Vector2.DOWN)
		if Input.is_action_pressed("ui_left") and !left.is_colliding():
			_move(Vector2.LEFT)
		if Input.is_action_pressed("ui_right") and !right.is_colliding():
			_move(Vector2.RIGHT)

func _move(direction: Vector2) -> void:
	global_position += direction * TILE_SIZE
	sprite.global_position -= direction * TILE_SIZE
	
	if tween:
		tween.kill()
	
	tween = create_tween()
	tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.tween_property(sprite, "global_position", global_position, 0.2).set_trans(Tween.TRANS_SINE)
