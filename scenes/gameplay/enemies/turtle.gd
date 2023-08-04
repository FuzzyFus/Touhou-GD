extends Enemy

var facing_left = true
@export var speed : Vector2 = Vector2()

func _process(_delta) -> void:
	linear_velocity = speed * Vector2(-1, 1) if facing_left else speed

func on_collision(ev) -> void:
	if ev.is_in_group("player_projectile"):
		hit()

	# ran into the player
	if ev.is_in_group("player"):
		var player = ev as Player
		if not player.invulnerable:
			player.hit()
			queue_free()

	# for bouncing
	if ev.is_in_group("world_boundary"):
		if ev.get_name() == "Left" or ev.get_name() == "Right":
			bounce()

func bounce() -> void:
	facing_left = not facing_left
