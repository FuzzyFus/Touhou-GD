extends Area2D

func _on_body_entered(ev):
	if ev.is_in_group("player_projectile") or ev.is_in_group("enemy_projectile") or ev.is_in_group("collectable"):
		if ev.get_class() == "Area2D":
			ev.get_parent().queue_free()
		else:
			ev.queue_free()
	elif ev.is_in_group("hardrock"):
		ev.explode()
