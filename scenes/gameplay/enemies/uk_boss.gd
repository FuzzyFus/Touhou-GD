extends Enemy

enum atk_type {NONE, TURTLE1, TURTLE2, SPIN1, NINECONE, LASER, HR}
var last_attack = atk_type.HR

@onready var turtle_obj = preload("res://scenes/gameplay/enemies/turtle.tscn")
@onready var bullet_obj = preload("res://scenes/gameplay/enemies/enemy_bullet.tscn")
@onready var s_shoot_turtle = preload("res://assets/sounds/2hu_e_tan0.wav")
@onready var s_shoot_bullet = preload("res://assets/sounds/2hu_e_tan1.wav")
@onready var shoot_player = $SFXPlayer/ShootPlayer as AudioStreamPlayer2D

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
					shoot_bullet($SpawnPoints/Spin.global_position, deg_to_rad(direction), 75)
				shoot_player.play()
				await(get_tree().create_timer(0.2).timeout)
		
		atk_type.NINECONE:
			pass
		atk_type.LASER:
			pass
		atk_type.HR:
			pass

func shoot_bullet(spawn_location, direction, speed):
	var bullet = bullet_obj.instantiate()
	get_parent().add_child(bullet)
	bullet.global_position = spawn_location
	bullet.ini(Vector2.from_angle(direction).normalized() * speed, "red")
	pass

func shoot_turtle():
	var turtle = turtle_obj.instantiate()
	get_parent().add_child(turtle)
	turtle.global_position = $SpawnPoints/Turtles.global_position
	shoot_player.stream = s_shoot_turtle
	shoot_player.play()
	
	return turtle
