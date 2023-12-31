extends Node2D

@onready var gameplay_obj = preload("res://scenes/gameplay/gameplay.tscn")
@onready var main_menu := $Menus/Main as Control
@onready var fps_label := $Overlay/FPS as Label
var gameplay

func _process(_d) -> void:
	fps_label.text = "FPS: " + str(Engine.get_frames_per_second())

func start_game() -> void:
	gameplay = gameplay_obj.instantiate()
	add_child(gameplay)
	# move gameplay to ensure ui input works as intended
	move_child(gameplay, 1)
	main_menu.hide()

func stop_game() -> void:
	gameplay.queue_free()
	main_menu.show()

# shortcut for retry button
func reload_game() -> void:
	stop_game()
	# wait 2 frames so things that update constantly update (ui) dont crash the game due to voided node variables
	# why 2 frames? idk why but 1 frame still causes the issue :'D
	await(get_tree().process_frame)
	await(get_tree().process_frame)
	start_game()
