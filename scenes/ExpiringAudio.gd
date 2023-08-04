# for one shot sounds that automatically delete
# only really intended for use with things that may overlap other sounds, or things that spawn audio on deletion
extends AudioStreamPlayer2D

func ini(target, source: AudioStream) -> void:
	stream = source
	
	match typeof(target):
		TYPE_VECTOR2:
			global_position = target
		TYPE_OBJECT:
			target.add_child(self)
		_:
			print("invalid ExpiringAudio created!")
			queue_free()
	play()

func finish() -> void:
	queue_free()
