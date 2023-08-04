extends RigidBody2D

@export var speed := Vector2(0,250)
@onready var sprite = $Sprite2D as Sprite2D

func ini(new_speed : Vector2, colour : String = "default"):
	speed = new_speed
	
	if colour != "default":
		var base_texture : AtlasTexture = sprite.texture
		sprite.texture = AtlasTexture.new()
		sprite.texture.atlas = base_texture.atlas
		
		# this is silly, but while im using 2hu sprites its worth
		match colour:
			_:
				sprite.texture.set_region(Rect2(8,57,16,16))
			"red":
				sprite.texture.set_region(Rect2(40,57,16,16))
			"purple":
				sprite.texture.set_region(Rect2(56,57,16,16))
			"blue":
				sprite.texture.set_region(Rect2(104,57,16,16))
			"green":
				sprite.texture.set_region(Rect2(168,57,16,16))
			"yellow":
				sprite.texture.set_region(Rect2(216,57,16,16))
			"orange":
				sprite.texture.set_region(Rect2(232,57,16,16))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_d):
	linear_velocity = speed

func on_collision(ev):
	print("wah " + str(ev))
	if ev.is_in_group("player"):
		var player = ev as Player
		if !player.invulnerable:
			player.hurt()
			queue_free()
