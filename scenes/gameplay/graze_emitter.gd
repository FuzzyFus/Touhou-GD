# this feels really silly and should be reworked but i dont got ideas rn :V
extends CPUParticles2D

func _ready():
	await(get_tree().create_timer(1).timeout)
	queue_free()
