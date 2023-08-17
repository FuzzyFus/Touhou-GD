extends ColorRect

@onready var vol_section := [$Bars/Master, $Bars/Spesifics/Player, $Bars/Spesifics/Enemy]
@onready var change_sound := $Audio as AudioStreamPlayer
var cur_bus := 0
var bar_tween : Tween
var colour_tween : Tween

func _ready():
	# make sure all busses are at their correct values
	var i := 0
	for bus in vol_section:
		update_bar(i)
		i += 1

func _input(ev) -> void:
	# if using precise scrolling change by 1%, else change volume by 10%
	var change_amount : float
	change_amount = 0.01 if Input.is_action_pressed("vol_precision") else 0.1
	
	if Input.is_action_pressed("vol_up"):
		change_vol(change_amount)
	
	elif Input.is_action_pressed("vol_down"):
		change_vol(change_amount * -1)

func update_bar(idx) -> void:
	# tween the bar value to make it smoothly jump to the value
	var bar := vol_section[idx].get_node("TextureProgressBar") as TextureProgressBar
	smart_tween(bar, "value", db_to_linear(AudioServer.get_bus_volume_db(idx)))
	
	# change percentage text
	vol_section[idx].get_node("Percentage").text = str( round(db_to_linear(AudioServer.get_bus_volume_db(idx)) * 100) )

func change_vol(value : float) -> void:
	# get new volume value 0-1, clamped 
	var new_vol = clamp( db_to_linear(AudioServer.get_bus_volume_db(cur_bus)) + value, 0, 1)
	
	# set value and change display
	AudioServer.set_bus_volume_db(cur_bus, linear_to_db(new_vol))
	update_bar(cur_bus)
	
	# play sound for feedback
	change_sound.pitch_scale = new_vol + 0.5
	change_sound.play()

# automatically changes on mouse over
func change_cur_bus(idx := 0) -> void:
	cur_bus = idx
	
	# change modulate of other channels
	var i := 0
	for section in vol_section:
		if idx == i:
			smart_tween(section, "modulate", Color(1,1,1,1))
		else:
			smart_tween(section, "modulate", Color(1,1,1,0.5))
		i += 1

# automatically disposing tween, because godot doesnt like chaining things without delay :^(
func smart_tween(object, property, final_val) -> void:
	# all smart tweens are gonna use this cuz its nice n snappy
	var tween = create_tween().set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	tween.tween_property(object, property, final_val, 0.2)
	await tween.finished
	tween.kill()
