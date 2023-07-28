extends Node
@export var speed := 10.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	self.rotation += delta * speed
