extends Control

var chars : Dictionary

var cutscene_data := ""
@onready var text_box := $Panel/RichTextLabel as RichTextLabel
var reimu_colour := "9999ff"
var uk_colour := "ff9999"
@onready var audio = $AudioStreamPlayer as AudioStreamPlayer
var s_uk2 = preload("res://assets/sounds/uk2.mp3")
var cur_scene := 0
var can_skip := true

@onready var reimu_portrait = $Potraits/Left as TextureRect
@onready var uk_portrait = $Potraits/Right as TextureRect

# this is silly, but this way lets you skip midway through
func update_cutscene(idx := 0):
	match idx:
		0:
			change_portraits()
			change_text("Hey, UK captain? Our team needs to reschedule our match.", reimu_colour)
			return
		1:
			change_portraits(false, 1)
			change_text("One of our members is having tech issues. Are you ok with 02:00 UTC-", reimu_colour)
			return
	
		2:
			can_skip = false
			change_portraits(true)
			change_text("you sent me a message first, yea?", uk_colour)
			audio.play()
			await(get_tree().create_timer(1.7).timeout)
			change_text("i live in smethwick, birmingham if you want the FUCKING brawl", uk_colour)
			await(get_tree().create_timer(2.4).timeout)
			change_text("COME down to smethwick, ask for DANNYG", uk_colour)
			await(get_tree().create_timer(2).timeout)
			audio.volume_db = linear_to_db(0.25)
			cur_scene = 3
			update_cutscene(3)
			return
	
		3:
			change_portraits(false, 3)
			change_text("Sigh... I guess we'll just play. Come on, then.", reimu_colour)
			return

# dummy function to accept input from any players off gameplay
# (future proofing for multiplayer and only taking input from player classes)
func advance_cutscene():
	if cur_scene != -1:
		if cur_scene < 2 and can_skip:
			cur_scene += 1
			update_cutscene(cur_scene)
		elif cur_scene == 3:
			end_cutscene()

func end_cutscene() -> void:
	if cur_scene == -1:
		return
	
	cur_scene = -1
	audio.volume_db = linear_to_db(1)
	audio.stream = s_uk2
	audio.play()
	
	self.hide()
	$"../..".start_game.emit()
	$"../..".timer_start()
	$"../..".game_started = false

func change_text(text := "", colour := "ffffff") -> void:
	var new_text := "[font_size=20]"
	new_text += "[color=" + colour + "]"
	new_text += text
	
	text_box.text = new_text

func change_portraits(side := false, portrait_idx := 0) -> void:
	# side: false = left/reimu, true = right/uk
	var target_portrait = uk_portrait if side else reimu_portrait
	var opposite_portrait = reimu_portrait if side else uk_portrait
	
	target_portrait.self_modulate = Color.WHITE
	opposite_portrait.self_modulate = Color.DIM_GRAY
	
	if side:
		return
	
	var texture = target_portrait.texture as AtlasTexture
	texture.region.position.x = (texture.region.size.x * portrait_idx)
