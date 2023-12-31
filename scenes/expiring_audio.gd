# for one shot sounds that automatically delete
# only really intended for use with things that may overlap other sounds, or things that spawn audio on deletion
extends AudioStreamPlayer2D

func ini(parent: Node, source: AudioStream, new_bus := "Master", position := Vector2.ZERO) -> void:
	parent.add_child(self)
	if position:
		global_position = position
	
	stream = source
	bus = new_bus
	play()

func finish() -> void:
	queue_free()
