extends Area2D

func _on_body_entered(ev):
	if ev.is_in_group("player_projectile") or ev.is_in_group("enemy_projectile") or ev.is_in_group("collectable") or ev.is_in_group("minion"):
		ev.queue_free()
