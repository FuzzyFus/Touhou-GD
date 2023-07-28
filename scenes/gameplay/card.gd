# acts as the collectibles ingame, giving points and power
class_name Card
extends RigidBody2D

enum type {POINT, POWER, MAX, ONEUP}
@export var current_type := type.POINT

var float_target
@onready var sprite := $Sprite2D as Sprite2D
@onready var hitbox := $Area2D/CollisionShape2D as CollisionShape2D

var players

func _ready() -> void:
	players = get_tree().get_nodes_in_group("player")
	# makes sure it changes to the type requested
	change_card_type(current_type)

func _physics_process(_delta) -> void:
	if float_target != null:
		apply_force(global_position.direction_to(float_target))

func change_card_type(new_type: int):
	current_type = new_type
	
	print(new_type)
	match new_type:
		type.POWER:
			sprite.texture.set_region(Rect2(8,336,16,16))
			hitbox.shape.size = Vector2(15,15)
		
		type.MAX:
			sprite.texture.set_region(Rect2(72,336,16,16))
			hitbox.shape.size = Vector2(20,20)
		
		type.ONEUP:
			sprite.texture.set_region(Rect2(88,336,16,16))
			hitbox.shape.size = Vector2(20,20)
		
		_: # type.POINT
			sprite.texture.set_region(Rect2(24,336,16,16))
			hitbox.shape.size = Vector2(15,15)

# i think this should be on the player but collision moment, far easier to be on here
func on_collision(ev):
	if ev.is_in_group("player"):
		var player = ev as Player
		
		match current_type:
			type.POWER:
				player.score += 15
				if player.power < 150:
					player.power += 1
			
			type.MAX:
				player.power = 150
			
			type.ONEUP:
				player.score += 50
				if player.lives < 5:
					player.lives += 1
			
			_: # type.POINT
				player.score += 15
		
		player.sfx_player.stream = player.s_pickup
		player.sfx_player.play()
		
		self.queue_free()

func float_to_player() -> void:
	var target_player : Player
	for player in players:
		# make sure there is a target player before comparing distance
		if target_player == null:
			target_player = player
		else:
			# if the position of this player is closer to the original target...
			if self.global_position.distance_to(player.global_position) < self.global_position.distance_to(target_player.global_position):
				target_player = player
	
	float_target = target_player
