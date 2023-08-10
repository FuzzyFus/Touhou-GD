extends Node

var expiring_audio = preload("res://scenes/expiring_audio.tscn")
# TODO: move this to gameplay script
var scene_card := preload("res://scenes/gameplay/card.tscn")

# made for timer class
func format_time(time) -> String:
	if time <= 0:
		return "00:00.00"
	var min : int = floor(time / 60)
	var sec : int = fmod(time, 60)
	var mil : int = fmod((time * 1000), 1000) / 10
	var str := "%02d:%02d.%02d" % [min, sec, mil]
	return str
