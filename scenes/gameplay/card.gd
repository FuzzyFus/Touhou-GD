# acts as the collectibles ingame, giving points and power
class_name Card
extends RigidBody2D

enum type {POINT, POWER, MAX, ONEUP}
@export var current_type := type.POINT

var float_target
var float_delta := 0.0
@onready var sprite := $Sprite2D as Sprite2D
@onready var hitbox := $Area2D/CollisionShape2D as CollisionShape2D

var players

func ini(spawn_position : Vector2, new_type: int = type.POINT, offset: Vector2 = Vector2(30,30)) -> void:
	change_card_type(new_type)
	global_position = spawn_position + offset * Vector2(randf_range(-1,1), randf_range(-1,1))
	pass
	
func _ready() -> void:
	# makes sure that the atlas can be safely changed
	var base_texture : AtlasTexture = sprite.texture
	sprite.texture = AtlasTexture.new()
	sprite.texture.atlas = base_texture.atlas
	
	# get players for float_to_player()
	players = get_tree().get_nodes_in_group("player")
	# makes sure it changes to the type requested
	change_card_type(current_type)

func _physics_process(_delta) -> void:
	if float_target != null:
		float_delta += _delta
		apply_force(global_position.direction_to(float_target.global_position) * max(500 - float_delta * 100, 0))

func change_card_type(new_type: int) -> void:
	current_type = new_type
	
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
func on_collision(ev) -> void:
	if ev.is_in_group("graze"): # redirect to player
		ev = ev.get_parent()
	
	if ev.is_in_group("player"):
		var player = ev as Player
		if !player.invulnerable:
			var old_level : int = clamp(floor(player.power / 50), 0, 2)
			
			match current_type:
				type.POWER:
					player.score += 15
					if player.power < 50:
						player.power += 1
				
				type.MAX:
					player.power = 50
				
				type.ONEUP:
					player.score += 50
					if player.lives < 5:
						player.lives += 1
						Global.expiring_audio.instantiate().ini(player, player.s_oneup)
				
				_: # type.POINT
					player.score += 15
			
			Global.expiring_audio.instantiate().ini(player, player.s_pickup)
			
			# if leveled up...
			if old_level < clamp(floor(player.power / 50), 0, 2):
				Global.expiring_audio.instantiate().ini(player, player.s_powerup)
			
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
