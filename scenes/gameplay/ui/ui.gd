extends Control

@onready var debug_text := $right/Label as Label
var players: Array

func _ready():
	players = get_tree().get_nodes_in_group("player")

func _process(delta):
	debug_text.text = "score: " + str(players[0].score)
	debug_text.text += "\npower: " + str(players[0].power)
	debug_text.text += "\nlives: " + str(players[0].lives)
