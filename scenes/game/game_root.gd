class_name GameRoot
extends Control

signal main_menu_requested


@onready var game: Game = %Game


func _ready() -> void:
	SignalBus.escape_requested.connect(_on_escape_requested)


func _on_escape_requested() -> void:
	main_menu_requested.emit()


func new_game() -> void:
	game.new_game()


func load_game() -> void:
	if not game.load_game():
		main_menu_requested.emit()


# TODO cleanup - sidebar as own scene
func _on_inventory_button_pressed() -> void:
	Input.action_press("activate")
