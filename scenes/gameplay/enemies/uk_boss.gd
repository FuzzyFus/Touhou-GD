extends Enemy

enum atk_type {NONE, TURTLE1, TURTLE2, SPIN1, CONE, LASER, HR}
var last_attacks = []
var attacking = false

@onready var turtle_obj = preload("res://scenes/gameplay/enemies/turtle.tscn")
@onready var bullet_obj = preload("res://scenes/gameplay/enemies/enemy_bullet.tscn")
@onready var hr_obj = preload("res://scenes/gameplay/enemies/hardrock.tscn")
@onready var s_shoot_turtle = preload("res://assets/sounds/2hu_e_tan0.wav")
@onready var s_shoot_bullet = preload("res://assets/sounds/2hu_e_tan1.wav")
@onready var swansong_obj = preload("res://scenes/gameplay/enemies/uk_swansong.tscn")
@onready var shoot_player = $SFXPlayer/ShootPlayer as AudioStreamPlayer2D
@onready var laser_player = $SFXPlayer/LaserPlayer as AudioStreamPlayer2D

func _process(_d) -> void:
	if not attacking:
		attack()

func attack() -> void:
	if attacking:
		return
	attacking = true
	var delay := 0.0
	
	# run rng to choose which attack
	var rng = randi_range(1,6)
	
	# check if rng is equal to the last 2 attacks
	while last_attacks.has(rng):
		if rng == 6:
			rng = 1
		else:
			rng += 1
		await(get_tree().create_timer(0.1).timeout)
	
	# store rng as an attack, so it wont repeat
	if last_attacks.size() >= 2:
		last_attacks.pop_back()
	last_attacks.push_front(rng)
	
	match rng:
		atk_type.TURTLE1:
			for i in 5:
				shoot_turtle()
				await(get_tree().create_timer(0.2).timeout)
			delay = 4
		
		atk_type.TURTLE2:
			for i in 6:
				if i % 2 == 0:
					shoot_turtle().facing_left = false
				else:
					shoot_turtle()
				
				await(get_tree().create_timer(0.2).timeout)
			delay = 4
		
		atk_type.SPIN1:
			var direction = 0.0
			var bullet_count = 10
			shoot_player.stream = s_shoot_bullet
			
			for i in 16: # total shots
				for b in bullet_count: # each bullet per shot
					# rotate bullet equally between each other
					direction = b * (360 / bullet_count) + $SpawnPoints/Spin.rotation_degrees
					shoot_bullet($SpawnPoints/Spin.global_position, direction, 75, "blue")
				shoot_player.play()
				await(get_tree().create_timer(0.2).timeout)
			delay = 3
		
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
			delay = 1
		
		atk_type.LASER:
			laser()
		
		atk_type.HR:
			for i in 3:
				var hr = hr_obj.instantiate()
				get_parent().add_child(hr)
				hr.global_position = $SpawnPoints/Cone/center.global_position
				await(get_tree().create_timer(2).timeout)
			delay = 4
		
		_: #failsafe
			pass
	
	await(get_tree().create_timer(delay).timeout)
	attacking = false

func shoot_bullet(spawn_location, direction: float, speed: float, colour := "red"):
	var bullet = bullet_obj.instantiate()
	get_parent().add_child(bullet)
	bullet.global_position = spawn_location
	bullet.ini(Vector2.from_angle(deg_to_rad(direction)).normalized() * speed, colour)

func shoot_turtle():
	var turtle = turtle_obj.instantiate()
	get_parent().add_child(turtle)
	turtle.global_position = $SpawnPoints/Turtles.global_position
	shoot_player.stream = s_shoot_turtle
	shoot_player.play()
	
	return turtle

func laser() -> void:
	laser_player.play()
	for i in 6: # total waves of bullets
		for x in 5: # amount of bullets in wave
					if i % 2 == 0: # for outside spawn points
						for b in 5:
							shoot_bullet(Vector2(-200 + (100 * b), -270), 90, 150, "yellow")
					else: # for inside spawn points
						for b in 4:
							shoot_bullet(Vector2(-150 + (100 * b), -270), 90, 150, "yellow")
					await(get_tree().create_timer(0.1).timeout)
		await(get_tree().create_timer(0.3).timeout)

func on_collision(ev) -> void:
	if health > 0:
		if ev.is_in_group("player_projectile"):
			hit()
		
		# ran into the player
		if ev.is_in_group("player"):
			var player = ev as Player
			if not player.invulnerable:
				player.hit()

func death() -> void:
	var swsng = swansong_obj.instantiate()
	get_parent().add_child(swsng)
	swsng.global_position = global_position
	
	await(get_tree().create_timer(0.1).timeout)
	var check = get_tree().get_nodes_in_group("swansong")
	if check.size() > 1:
		var x = 0
		for obj in check:
			if x > 0:
				obj.queue_free()
			x += 1
	
	queue_free()

