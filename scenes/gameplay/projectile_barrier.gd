extends Area2D

func _on_body_entered(ev):
	if ev.is_in_group("projectile"):
		ev.queue_free()
