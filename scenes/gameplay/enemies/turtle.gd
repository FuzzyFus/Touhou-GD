extends RigidBody2D

@export var health : int = 9
@onready var sfx_player := $SFXPlayer as AudioStreamPlayer2D

var facing_left = true
@export var speed : Vector2 = Vector2()

# TODO: no!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! put this in a gameplay script!!!!!!!!!!!
var scene_card := preload("res://scenes/gameplay/card.tscn")

func _process(_delta) -> void:
	linear_velocity = speed * Vector2(-1, 1) if facing_left else speed

func death(point_cards: int, power_cards: int = 0, oneup_cards: int = 0) -> void:
	#spawn cards based on input, with random velocity to make it "explode"
	for card in point_cards:
		var instance = scene_card.instantiate()
		get_parent().add_child(instance)
		instance.ini(self.global_position)
		
	for card in power_cards:
		var instance = scene_card.instantiate()
		get_parent().add_child(instance)
		instance.ini(self.global_position, 1)
	
	for card in oneup_cards:
		var instance = scene_card.instantiate()
		get_parent().add_child(instance)
		instance.ini(self.global_position, 3)
	
	queue_free()

func hit() -> void:
	# TODO: instant disposing AudioStreamPlayer2D again
	sfx_player.play()
	health -= 1
	if health <= 0:
		death(5,1,0)
	pass

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
	
	#linear_velocity = speed * Vector2(-1, 1)
