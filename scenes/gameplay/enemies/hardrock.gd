extends RigidBody2D

var grazed = false
var direction : Vector2
var speed := 500.0
var locked_in := false
var target

@onready var bullet_obj = preload("res://scenes/gameplay/enemies/enemy_bullet.tscn")

@onready var SFXPlayer := $SFXPlayer as AudioStreamPlayer2D
@onready var s_charge := preload("res://assets/sounds/2hu_e_charge.wav") as AudioStream
@onready var s_nyoom := preload("res://assets/sounds/voc_nyoom.mp3") as AudioStream
@onready var s_boom := preload("res://assets/sounds/voc_boom.wav") as AudioStream

func _ready() -> void:
	# find out who the closest target is
	var all_players = get_tree().get_nodes_in_group("player")
	for player in all_players:
		if not target:
			target = player
		# if this player is closer to us than the current target...
		elif player.global_position.distance_to(self.global_position) < target.global_position.distance_to(self.global_position):
			target = player
	
	SFXPlayer.play()
	
	await(get_tree().create_timer(2.5).timeout)
	locked_in = true
	
	SFXPlayer.stream = s_nyoom
	SFXPlayer.play()

func _physics_process(_d):
	if not locked_in: # do timer and rotate to target
		look_at(target.global_position)
		direction = global_position.direction_to(target.global_position)
		
	else:
		linear_velocity = direction * speed

func explode():
	speed = 0
	for b in 30:
		# yes i know this looks ridiculous
		# direction is the opposite way the HR is moving with 90 degrees of added randomness
		shoot_bullet(self.global_position, rotation_degrees - 180 + randf_range(-25,25), randf_range(50,200))
	
	Global.expiring_audio.instantiate().ini(get_parent(), s_boom, "Enemy", self.global_position)
	queue_free()

func shoot_bullet(spawn_location: Vector2, direction: float, speed: float):
	var bullet = bullet_obj.instantiate()
	get_parent().add_child(bullet)
	bullet.global_position = spawn_location
	bullet.ini(Vector2.from_angle(deg_to_rad(direction)).normalized() * speed, "orange", 100)

func on_collision(ev) -> void:
	if ev.is_in_group("player"):
		var player = ev as Player
		if not player.invulnerable:
			player.hit()
			explode()
