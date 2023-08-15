# TODO: make this actually a class instead of just the player script that happens to be a class www
# would be nice for multiplayer

class_name Player
extends CharacterBody2D

# basic player vars
@export var power = 0
@export var score = 0
@export var lives = 1
const SPEED := 250.0

var dead = false

@export var shooting_delay := 0.3
var damage_delay := 3.0
var can_shoot := true
@export var invulnerable := false
var slow := false
var active := false

# TODO: this is stupid. i should probably make a new script for this but im stubborn
var ball_t := 0.0

@onready var animtree := $AnimationTree as AnimationTree
@onready var damagetree := $DamageTree as AnimationTree
@onready var sprite := $Sprite as AnimatedSprite2D

@onready var graze_emitter := $Graze/GrazeEmitter as CPUParticles2D

# sound related
@onready var sfx_player := $SFXPlayer as AudioStreamPlayer2D
@onready var shoot_player := $SFXPlayer/ShootPlayer as AudioStreamPlayer2D
@onready var death_player := $SFXPlayer/DeathPlayer as AudioStreamPlayer2D
@onready var s_pickup := preload("res://assets/sounds/2hu_pickup.wav") as AudioStream
@onready var s_powerup := preload("res://assets/sounds/2hu_powerup.wav") as AudioStream
@onready var s_hit := preload("res://assets/sounds/2hu_p_death.wav") as AudioStream
@onready var s_death := preload("res://assets/sounds/voc_aaaaa.mp3") as AudioStream
@onready var s_oneup := preload("res://assets/sounds/se_bonus.wav") as AudioStream

@onready var m_greyscale := preload("res://assets/shaders/greyscale.gdshader") as Shader

# external assets
var bullet := preload("res://scenes/gameplay/player_bullet.tscn")
@onready var timer := $Timer as Timer

signal shoot_pressed
signal slow_pressed

func _physics_process(delta) -> void:
	if lives > 0 and active:
		movement()
		shooting()
		move_balls(delta)
		update_animtree()
	if dead:
		velocity.y += delta

func shooting() -> void:
	if can_shoot and not invulnerable and Input.is_action_pressed("shoot"):
		# spawn bullet(s)
		# TODO: this code looks bad and i should feel bad! make it iterate?
		match floor(power / 25):
			0: # level 1, 0 cards. single shot
				var middle = bullet.instantiate()
				get_parent().add_child(middle)
				middle.position = self.position
				
			1: # level 2, 25 cards. double shot
				var left = bullet.instantiate()
				get_parent().add_child(left)
				left.position = self.position + Vector2(0,0)
				left.ini(Vector2.from_angle(deg_to_rad(-95)).normalized() * 1000)
				
				var right = bullet.instantiate()
				get_parent().add_child(right)
				right.position = self.position + Vector2(0,0)
				right.ini(Vector2.from_angle(deg_to_rad(-85)).normalized() * 1000)
			
			_: # level 3, 50+ cards. triple shot
				var left = bullet.instantiate()
				get_parent().add_child(left)
				left.position = self.position + Vector2(-10,0)
				left.rotation_degrees = 15
				left.ini(Vector2.from_angle(deg_to_rad(-97)).normalized() * 1000)
				
				var middle = bullet.instantiate()
				get_parent().add_child(middle)
				middle.position = self.position + Vector2(0,-10)
				middle.ini(Vector2.from_angle(deg_to_rad(-90)).normalized() * 1000)
				
				var right = bullet.instantiate()
				get_parent().add_child(right)
				right.position = self.position + Vector2(10,0)
				right.ini(Vector2.from_angle(deg_to_rad(-83)).normalized() * 1000)
				pass
		
		shoot_player.play()
		
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
	if not invulnerable and lives > 0:
		lives -= 1
		if lives <= 0:
			die()
			return
		
		damagetree["parameters/conditions/hit"] = true
		sfx_player.stream = s_hit
		sfx_player.play()

func _input(ev) -> void:
	if ev is InputEventKey:
		if ev.is_action_pressed("slow"):
			ball_t = 0
			slow = true
		elif ev.is_action_released("slow"):
			ball_t = 0
			slow = false
		
		if ev.is_action_pressed("shoot"):
			shoot_pressed.emit()
		if ev.is_action_pressed("slow"):
			slow_pressed.emit()

func update_animtree() -> void:
	var pressing = Input.is_action_pressed("left") or Input.is_action_pressed("right")
	
	animtree["parameters/conditions/pressing"] = pressing
	animtree["parameters/conditions/not_pressing"] = not pressing
	
	# hate this, but to make it not flip with no input, this is the best for now
	if Input.is_action_pressed("left") and Input.is_action_pressed("right"):
		return
	elif Input.is_action_pressed("left"):
		sprite.flip_h = false
	elif Input.is_action_pressed("right"):
		sprite.flip_h = true 

func check_graze(ev) -> void:
	if ev.is_in_group("enemy_projectile") and invulnerable == false and lives > 0:
		ev = ev.get_parent()
		if ev.grazed == false:
			ev.grazed = true
			graze_emitter.restart()
			graze_emitter.emitting = true
			$Graze/GrazePlayer.play()
			score += 1

func die() -> void:
	if not dead:
		# stop everything
		$Hitbox.set_deferred("disabled", true)
		
		# TODO: GROSS CODE GROSS CODE NOOOOOOOOOOOOO I HATE THIS
		var greyscale = ShaderMaterial.new()
		greyscale.shader = m_greyscale
		sprite.set_material(greyscale)
		
		death_player.play()
		await(get_tree().create_timer(1).timeout)
		
		var dead = true
		
		# I ALSO HATE THIS CODE! GROSS! DISGUSTING! FILTHY! :((((((((((((((((((((((((((((
		# makes a rigid body to make player spin
		var rb = RigidBody2D.new()
		get_parent().add_child(rb)
		rb.global_position = self.global_position
		get_parent().remove_child(self)
		rb.add_child(self)
		self.position = Vector2.ZERO
		rb.inertia = 0.01
		rb.gravity_scale = 0.3
		rb.apply_central_impulse(Vector2(randf_range(-50,50),-200))
		rb.apply_torque_impulse(0.2)
		
		death_player.stream = s_death
		death_player.play()

func toggle_active() -> void:
	active = not active
