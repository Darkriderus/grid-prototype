extends Node

signal player_died
signal player_descended
signal message_sent(text, color)
signal escape_requested
signal coord_selected(coord: Vector2i)
signal entities_focussed(entity_list)

signal player_turn_started
