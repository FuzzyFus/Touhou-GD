extends Node
@export var speed := 10.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta) -> void:
	self.rotation += delta * speed
