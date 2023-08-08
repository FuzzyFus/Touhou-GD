extends Enemy

enum atk_type {NONE, TURTLE1, TURTLE2, SPIN1, CONE, LASER, HR}
var last_attack = atk_type.HR

@onready var turtle_obj = preload("res://scenes/gameplay/enemies/turtle.tscn")
@onready var bullet_obj = preload("res://scenes/gameplay/enemies/enemy_bullet.tscn")
@onready var s_shoot_turtle = preload("res://assets/sounds/2hu_e_tan0.wav")
@onready var s_shoot_bullet = preload("res://assets/sounds/2hu_e_tan1.wav")
@onready var shoot_player = $SFXPlayer/ShootPlayer as AudioStreamPlayer2D
@onready var laser_player = $SFXPlayer/LaserPlayer as AudioStreamPlayer2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func attack() -> void:
	# run rng to choose which attack
	match randi_range(1,6):
		atk_type.TURTLE1:
			for i in 5:
				shoot_turtle()
				await(get_tree().create_timer(0.5).timeout)
		
		atk_type.TURTLE2:
			for i in 6:
				if i % 2 == 0:
					shoot_turtle().facing_left = false
				else:
					shoot_turtle()
				
				await(get_tree().create_timer(0.2).timeout)
		
		atk_type.SPIN1:
			var direction = 0.0
			var bullet_count = 10
			shoot_player.stream = s_shoot_bullet
			
			for i in 16: # total shots
				for b in bullet_count: # each bullet per shot
					# rotate bullet equally between each other
					direction = b * (360 / bullet_count) + $SpawnPoints/Spin.rotation_degrees
					shoot_bullet($SpawnPoints/Spin.global_position, direction, 75)
				shoot_player.play()
				await(get_tree().create_timer(0.2).timeout)
		
		atk_type.CONE:
			shoot_player.stream = s_shoot_bullet
			for i in 15:
				shoot_bullet($SpawnPoints/Cone/center.global_position, 90, 100)
				shoot_bullet($SpawnPoints/Cone/one.global_position, 80, 100)
				shoot_bullet($SpawnPoints/Cone/two.global_position, 70, 100)
				shoot_bullet($SpawnPoints/Cone/three.global_position, 60, 100)
				shoot_bullet($SpawnPoints/Cone/four.global_position, 50, 100)
				
				shoot_bullet($SpawnPoints/Cone/one.global_position * Vector2(-1,1), 100, 100)
				shoot_bullet($SpawnPoints/Cone/two.global_position * Vector2(-1,1), 110, 100)
				shoot_bullet($SpawnPoints/Cone/three.global_position * Vector2(-1,1), 120, 100)
				shoot_bullet($SpawnPoints/Cone/four.global_position * Vector2(-1,1), 130, 100)
				shoot_player.play()
				await(get_tree().create_timer(0.2).timeout)
		atk_type.LASER:
			laser_player.play()
			for i in 6: # total waves of bullets
				for x in 5: # amount of bullets in wave
							if i % 2 == 0: # for outside spawn points
								for b in 5:
									shoot_bullet(Vector2(-200 + (100 * b), -270), 90, 150)
							else: # for inside spawn points
								for b in 4:
									shoot_bullet(Vector2(-150 + (100 * b), -270), 90, 150)
							await(get_tree().create_timer(0.1).timeout)
				await(get_tree().create_timer(0.3).timeout)
		atk_type.HR:
			pass

func shoot_bullet(spawn_location: Vector2, direction: float, speed: float):
	var bullet = bullet_obj.instantiate()
	get_parent().add_child(bullet)
	bullet.global_position = spawn_location
	bullet.ini(Vector2.from_angle(deg_to_rad(direction)).normalized() * speed, "red")

func shoot_turtle():
	var turtle = turtle_obj.instantiate()
	get_parent().add_child(turtle)
	turtle.global_position = $SpawnPoints/Turtles.global_position
	shoot_player.stream = s_shoot_turtle
	shoot_player.play()
	
	return turtle
