class_name Gameplay
extends Node2D

var start_time : int
@onready var timer = $GameTimer as Timer
@onready var ui = $UI as Control
@onready var ukboss := $UKBoss as Enemy
var players : Array

@onready var cutscene := $UI/CutsceneUI

signal accept_menu
signal start_game

func _ready():
	ui.ini(ukboss.health)
	
	start_game.connect(ukboss.toggle_attacking)
	
	players = get_tree().get_nodes_in_group("player")
	for player in players:
		player.shoot_pressed.connect(accept_menu_func)
		#timer.timeout.connect(player.die)
		start_game.connect(player.toggle_active)

func _process(_d):
	# send data to ui script
	var data: Dictionary = {"BossHealth": 0, "TimeLeft": 0}
	
	data["TimeLeft"] = timer.time_left
	if ukboss != null:
		data["BossHealth"] = ukboss.health
	
	ui.update_ui(data, players)

func timer_start() -> void:
	timer.start(5) # 5 minutes

func accept_menu_func() -> void:
	accept_menu.emit()

