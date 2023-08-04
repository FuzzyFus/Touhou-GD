# for one shot sounds that automatically delete
extends AudioStreamPlayer2D

func ini(target, source: AudioStream) -> void:
	stream = source
	
	if target.get_class() == "Vector2":
		global_position = target
	elif target != null:
		target.add_child(self)

func finish() -> void:
	queue_free()
