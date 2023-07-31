# TODO: make this actually a class instead of just the player script that happens to be a class www
# important for card collision n such
class_name Player
extends CharacterBody2D

# basic player vars
@export var power = 0
@export var score = 0
@export var lives = 1
const SPEED := 300.0

@export var shooting_delay := 0.3
var damage_delay := 3.0
var can_shoot := true
var slow := false

# TODO: this is stupid. i should probably make a new script for this but im stubborn
var ball_t := 0.0

# sound related
@onready var sfx_player := $SFXPlayer as AudioStreamPlayer2D
@onready var s_shoot := preload("res://assets/sounds/2hu_p_shoot.wav") as AudioStream
@onready var s_pickup := preload("res://assets/sounds/2hu_pickup.wav") as AudioStream
@onready var s_powerup := preload("res://assets/sounds/2hu_powerup.wav") as AudioStream

# external assets
var bullet := preload("res://scenes/gameplay/player_bullet.tscn")
@onready var timer := $Timer as Timer

func _physics_process(delta) -> void:
	movement()
	shooting()
	move_balls(delta)
	
func shooting() -> void:
	if can_shoot and Input.is_action_pressed("shoot"):
		
		# spawn bullet(s)
		# TODO: this code looks bad and i should feel bad! make it iterate?
		match floor(power / 50):
			0: # level 1, 50 cards. single shot
				var middle = bullet.instantiate()
				get_parent().add_child(middle)
				middle.position = self.position
				
			1: # level 2, 100 cards. double shot
				var left = bullet.instantiate()
				get_parent().add_child(left)
				left.position = self.position + Vector2(-10,0)
				
				var right = bullet.instantiate()
				get_parent().add_child(right)
				right.position = self.position + Vector2(10,0)
			
			_: # level 3, 150+ cards. triple shot
				var left = bullet.instantiate()
				get_parent().add_child(left)
				left.position = self.position + Vector2(-15,0)
				
				var middle = bullet.instantiate()
				get_parent().add_child(middle)
				middle.position = self.position + Vector2(0,-10)
				
				var right = bullet.instantiate()
				get_parent().add_child(right)
				right.position = self.position + Vector2(15,0)
				pass
		
		# play sfx
		sfx_player.stream = s_shoot
		sfx_player.play()
		
		# prevent player from shooting, and start timer to reenable shooting
		can_shoot = false
		timer.start(shooting_delay)

func movement() -> void:
	var direction := Vector2(Input.get_axis("left", "right"), Input.get_axis("up", "down")).normalized()
	
	var final_speed : float = SPEED / 2 if slow else SPEED
	
	if direction:
		velocity = direction * final_speed
		
	else:
		velocity.x = move_toward(velocity.x, 0, final_speed)
		velocity.y = move_toward(velocity.y, 0, final_speed)

	move_and_slide()

func timer_ended() -> void:
	can_shoot = true

func move_balls(delta) -> void:
	ball_t += delta * 5
	ball_t = clamp(ball_t,0,1)
	
	var sidePos = Vector2(22,0)
	var frontPos = Vector2(8,-30)
	
	if slow:
		$RightBall.position = sidePos.lerp(frontPos, ball_t)
		$LeftBall.position = sidePos.lerp(frontPos, ball_t) * Vector2(-1,1)
	else:
		$RightBall.position = frontPos.lerp(sidePos, ball_t)
		$LeftBall.position = frontPos.lerp(sidePos, ball_t) * Vector2(-1,1)

func hit() -> void:
	pass

func _input(ev) -> void:
	if ev is InputEventKey:
		if ev.is_action_pressed("slow"):
			ball_t = 0
			slow = true
		elif ev.is_action_released("slow"):
			ball_t = 0
			slow = false
