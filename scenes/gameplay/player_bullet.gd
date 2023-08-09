# this is silly. i should make a bullet class
extends RigidBody2D

@export var speed := Vector2(0,-1000)

func _physics_process(_d):
	linear_velocity = speed

func ini(new_speed : Vector2):
	speed = new_speed

func on_collision(ev):
	pass
	# TODO: FIX MEEEEEEEEEEEEEEEEEEEEEE BULLETS DONT REMOVE WHEN COLLIDING
	#print(ev.get_groups())
	# this crashes the engine
#	if ev.is_in_group("enemy"):
#		var enemy = ev as Enemy
#		enemy.hit()
#		queue_free()
