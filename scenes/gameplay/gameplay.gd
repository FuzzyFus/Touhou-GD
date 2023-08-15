class_name Gameplay
extends Node2D

var start_time : int
@onready var timer = $GameTimer as Timer
@onready var ui = $UI as Control
@onready var end_menu = $UI/EndMenu as Control
@onready var ukboss := $UKBoss as Enemy
var players : Array
var dead_players := 0
var root

@onready var cutscene := $UI/CutsceneUI
var game_started := false

signal accept_menu
signal skip_menu
signal start_game

func _ready():
	root = $".."
	print(root)
	ui.ini(ukboss.health)
	
	start_game.connect(ukboss.toggle_attacking)
	
	players = get_tree().get_nodes_in_group("player")
	for player in players:
		player.shoot_pressed.connect(accept_menu_func)
		player.slow_pressed.connect(skip_menu_func)
		player.player_died.connect(player_died)
		timer.timeout.connect(player.die)
		
		start_game.connect(player.toggle_active)
	
	await(get_tree().create_timer(2).timeout)
	cutscene.start_cutscene()
	
	$UI/EndMenu/Buttons/RetryButton.pressed.connect(root.reload_game)
	$UI/EndMenu/Buttons/MenuButton.pressed.connect(root.stop_game)

func _process(_d):
	# send data to ui script
	var data: Dictionary = {"BossHealth": 0, "TimeLeft": 0}
	
	data["TimeLeft"] = timer.time_left
	if ukboss != null:
		data["BossHealth"] = ukboss.health
	
	ui.update_ui(data, players)

func timer_start() -> void:
	timer.start(300) # 5 minutes

func accept_menu_func() -> void:
	if not game_started:
		cutscene.advance_cutscene()
	
func skip_menu_func() -> void:
	if not game_started:
		cutscene.end_cutscene()

func player_died() -> void:
	dead_players += 1
	if dead_players >= players.size():
		
		print("all players died")
		await(get_tree().create_timer(2).timeout)
		open_end_menu()

func open_end_menu() -> void:
	end_menu.show()
	if dead_players >= players.size(): # if lost...
		end_menu.get_node("Label").text = "ya dun goof'd"

func boss_killed() -> void:
	# give player some time to grab all the cards n stuff for their final score
	timer.paused = true
	await(get_tree().create_timer(5).timeout)
	
	# give players extra score for the leftover time
	for player in players:
		player.score += floor(timer.time_left)
	
	open_end_menu()
