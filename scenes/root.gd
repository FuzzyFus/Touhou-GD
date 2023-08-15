extends Node2D

@onready var gameplay_obj = preload("res://scenes/gameplay/gameplay.tscn")
@onready var main_menu := $Menus/Main as Control
var gameplay

func start_game() -> void:
	gameplay = gameplay_obj.instantiate()
	get_parent().add_child(gameplay)
	main_menu.hide()

func stop_game() -> void:
	gameplay.queue_free()
	main_menu.show()

# shortcut for retry button
func reload_game() -> void:
	stop_game()
	start_game()
