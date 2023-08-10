class_name Gameplay
extends Node2D

var start_time : int
@onready var timer = $GameTimer as Timer
@onready var ui = $UI as Control
@onready var ukboss := $UKBoss as Enemy
var players : Array

func _ready():
	ui.ini(ukboss.health)
	players = get_tree().get_nodes_in_group("player")
	timer.start(300) # 5 minutes

func _process(_d):
	# send data to ui script
	var data: Dictionary = {"BossHealth": 0, "TimeLeft": 0}
	
	data["TimeLeft"] = timer.time_left
	if ukboss != null:
		data["BossHealth"] = ukboss.health
		
	ui.update_ui(data)

func timer_ended() -> void:
	# kill players automatically
	pass
