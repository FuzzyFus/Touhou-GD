# class for any object that can get hit, die, and hurts player if touched
class_name Enemy
extends RigidBody2D

var grazed = false
@export var drops := {"point_cards": 3, "power_cards": 1, "oneup_cards": 0}
@export var health : int = 9
@onready var sfx_player := $SFXPlayer as AudioStreamPlayer2D

func hit() -> void:
	sfx_player.play()
	health -= 1
	if health <= 0:
		death()
	pass

func death() -> void:
	#spawn cards based on input, with random velocity to make it "explode"
	
	for card in drops["point_cards"]:
		var instance = Global.scene_card.instantiate()
		get_parent().add_child(instance)
		instance.ini(self.global_position)
		
	for card in drops["power_cards"]:
		var instance = Global.scene_card.instantiate()
		get_parent().add_child(instance)
		instance.ini(self.global_position, 1)
	
	for card in drops["oneup_cards"]:
		var instance = Global.scene_card.instantiate()
		get_parent().add_child(instance)
		instance.ini(self.global_position, 3)
	
	queue_free()

func on_collision(ev) -> void:
	if ev.is_in_group("player_projectile"):
		hit()
	
	# ran into the player
	if ev.is_in_group("player"):
		var player = ev as Player
		if not player.invulnerable:
			player.hit()
			queue_free()
