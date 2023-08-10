# i absolutely hate how this is done but i want to avoid circular dependency, please review later
extends Control

@onready var debug_text := $right/Label as Label
@onready var boss_health_counter := $BossUI/HealthCounter as Control
@onready var boss_timer := $BossUI/TimerLabel as Label
@onready var hb := $BossUI/HealthBar as ColorRect
@onready var hb_fill := $BossUI/HealthBar/Fill as ColorRect
var boss_max_health := 1

func ini(bmh : int) -> void:
	boss_max_health = bmh

func update_ui(data : Dictionary):
	boss_timer.text = Global.format_time(data["TimeLeft"])
	boss_health_counter.text = str(data["BossHealth"]) + "/" + str(boss_max_health)
	hb_fill.size = Vector2(float(data["BossHealth"]) / float(boss_max_health) * hb.size.x, hb.size.y)
	
#	debug_text.text = "score: " + str(players[0].score)
#	debug_text.text += "\npower: " + str(players[0].power) + "/50"
#	debug_text.text += "\nlives: " + str(players[0].lives)
	pass
