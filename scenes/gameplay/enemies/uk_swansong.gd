extends Enemy

@onready var bullet_obj = preload("res://scenes/gameplay/enemies/enemy_bullet.tscn")
@onready var s_explode = preload("res://assets/sounds/se_bigboom.wav")

@onready var shoot_player = $SFXPlayer/ShootPlayer as AudioStreamPlayer2D

func shoot_bullet(spawn_location, direction: float, speed: float, colour := "red"):
	var bullet = bullet_obj.instantiate()
	get_parent().add_child(bullet)
	bullet.global_position = spawn_location
	bullet.ini(Vector2.from_angle(deg_to_rad(direction)).normalized() * speed, colour)

func _ready() -> void:
	# take turns between bullet speeds, getting faster
	# timer here to make sure theres no weirdness while it instantiates
	await(get_tree().create_timer(0.1).timeout)

	for i in 12:
		shoot_bullet(global_position, randf_range(0,360), 100, "blue")
		shoot_player.play()
		await(get_tree().create_timer(0.25).timeout)
	for i in 20:
		shoot_bullet(global_position, randf_range(0,360), 150, "yellow")
		shoot_player.play()
		await(get_tree().create_timer(0.15).timeout)
	for i in 35:
		shoot_bullet(global_position, randf_range(0,360), 200)
		shoot_player.play()
		await(get_tree().create_timer(0.075).timeout)
	
	await(get_tree().create_timer(1).timeout)
	sfx_player.queue_free()
	
	Global.expiring_audio.instantiate().ini(get_parent(), s_explode, self.global_position)
	for i in 150:
		shoot_bullet(global_position, randf_range(0,360), randf_range(100,250), "orange")

	for card in drops["point_cards"]:
		var instance = Global.scene_card.instantiate()
		get_parent().add_child(instance)
		instance.ini(self.global_position, 0, card_spread)

	for card in drops["power_cards"]:
		var instance = Global.scene_card.instantiate()
		get_parent().add_child(instance)
		instance.ini(self.global_position, 1, card_spread)

	for card in drops["oneup_cards"]:
		var instance = Global.scene_card.instantiate()
		get_parent().add_child(instance)
		instance.ini(self.global_position, 3, card_spread)
	queue_free()
