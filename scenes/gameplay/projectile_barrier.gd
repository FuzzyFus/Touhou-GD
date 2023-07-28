extends Area2D

func _on_body_entered(ev):
	print("collectable: " + str(ev.is_in_group("collectable")))
	if ev.is_in_group("projectile") or ev.is_in_group("collectable"):
		ev.queue_free()
