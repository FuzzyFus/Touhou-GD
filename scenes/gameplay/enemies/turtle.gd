extends RigidBody2D

var facing_left = true
@export var speed : Vector2 = Vector2()

func _ready() -> void:
	linear_velocity = speed

func death(point_cards: int, power_cards: int = 0, oneup_cards: int = 0):
	#spawn cards based on input, with random velocity to make it "explode"
	pass

func on_collision(ev):
	print("WHAAAAAAAAAAAAT")
	print(str(ev.get_groups()))
	if ev.is_in_group("player"):
		# hit player
		var player = ev as Player
		player.hit()
	if ev.is_in_group("world_boundary"):
		print(ev.get_name())
		if ev.get_name() == "Left" or ev.get_name() == "Right":
			print("SEXO")
			bounce()

func bounce():
	facing_left = not facing_left
	
	linear_velocity = speed * Vector2(-1, 1)
