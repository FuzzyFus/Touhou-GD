# this is silly. i should make a bullet class
extends RigidBody2D

@export var speed := Vector2(0,-1000)

func _physics_process(_d):
	linear_velocity = speed

func ini(new_speed : Vector2):
	speed = new_speed

func on_collision(ev):
	# TODO: FIX MEEEEEEEEEEEEEEEEEEEEEE BULLETS DONT REMOVE WHEN COLLIDING
	if ev.is_in_group("enemy"):
		if ev.get_class() == "Area2D":
			ev = ev.get_parent()
		var enemy = ev as Enemy
		enemy.hit()
		queue_free()
