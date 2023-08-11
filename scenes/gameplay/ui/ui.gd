# i absolutely hate how this is done but i want to avoid circular dependency, please review later
extends Control

@onready var boss_health_counter := $BossUI/HealthCounter as Control
@onready var boss_timer := $BossUI/TimerLabel as Label
@onready var hb := $BossUI/HealthBar as ColorRect
@onready var hb_fill := $BossUI/HealthBar/Fill as ColorRect
var boss_max_health := 1

@onready var player_container := $right/Players as VBoxContainer
var ingame_players : Array

func ini(bmh : int) -> void:
	boss_max_health = bmh

func update_ui(data : Dictionary, players : Array) -> void:
	# boss related
	boss_timer.text = Global.format_time(data["TimeLeft"])
	boss_health_counter.text = str(data["BossHealth"]) + "/" + str(boss_max_health)
	hb_fill.size = Vector2(float(data["BossHealth"]) / float(boss_max_health) * hb.size.x, hb.size.y)
	
	var x = 0
	for player in player_container.get_children():
		var score_str := str(players[x].score)
		# a tad silly, but formatting to make it always nine digits
		var needed_zeros = 9 - score_str.length()
		if needed_zeros > 0:
			for zero in needed_zeros:
				score_str = "0" + score_str
		
		player.get_node("Score").text = "Score " + score_str
		player.get_node("Power").text = "Power " + str(players[x].power) + "/50"
		change_stocks(x, players[x])
		
		x += 1
	pass

# TODO: this should not be called every frame and should use a signal
func change_stocks(player_idx : int, player : Player) -> void:
	# get each child in the lives bar for the respective player
	var x := 1 # start on 1 to ignore text
	for stock in player_container.get_child(player_idx).get_node("Lives").get_children():
		if stock.is_class("TextureRect"):
			stock.set_visible(x - 1 <= player.lives)
			if x >= player_container.get_child(player_idx).get_node("Lives").get_child_count():
				return
		x += 1
