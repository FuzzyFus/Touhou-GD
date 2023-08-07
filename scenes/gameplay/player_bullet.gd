# this is silly. i should make a bullet class
extends RigidBody2D

@export var speed := Vector2(0,-1000)

func _physics_process(_d):
	linear_velocity = speed

func ini(new_speed : Vector2):
	speed = new_speed
