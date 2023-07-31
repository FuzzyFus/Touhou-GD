extends RigidBody2D

@export var health : int = 12
@onready var sfx_player := $SFXPlayer as AudioStreamPlayer2D

var facing_left = true
@export var speed : Vector2 = Vector2()

func _process(delta) -> void:
	linear_velocity = speed * Vector2(-1, 1) if facing_left else speed

func _ready() -> void:
	#linear_velocity = speed
	pass

func death(point_cards: int, power_cards: int = 0, oneup_cards: int = 0) -> void:
	#spawn cards based on input, with random velocity to make it "explode"
	pass

func hit() -> void:
	sfx_player.play()
	health -= 1
	if health >= 0:
		death(5,1,0)
	pass

func on_collision(ev) -> void:
	if ev.is_in_group("player_projectile"):
		hit()
	if ev.is_in_group("player"):
		# hit player
		var player = ev as Player
		player.hit()
	if ev.is_in_group("world_boundary"):
		if ev.get_name() == "Left" or ev.get_name() == "Right":
			bounce()

func bounce() -> void:
	facing_left = not facing_left
	
	#linear_velocity = speed * Vector2(-1, 1)
