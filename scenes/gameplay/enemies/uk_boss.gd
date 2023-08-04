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
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
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
			pass
		atk_type.NINECONE:
			pass
		atk_type.LASER:
			pass
		atk_type.HR:
			pass

func shoot_turtle():
	var turtle = turtle_obj.instantiate()
	get_parent().add_child(turtle)
	turtle.global_position = $SpawnPoints/Turtles.global_position
	shoot_player.stream = s_shoot_turtle
	shoot_player.play()
	
	return turtle
