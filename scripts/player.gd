extends CharacterBody2D
class_name Player


@export var animated_sprite: AnimatedSprite2D
@export var collider: CollisionShape2D
@export var death_timer: Timer

@onready var map: TileMap = %TileMap

signal player_died

var _input_direction: int
var _direction_x: int = 1
var _cayote_time_remaining: float
var _is_alive: bool = true

const GROUND_ACCELERATION = 780
const AIR_ACCELERATION = 600
const GRAVITY_ACCELERATION = 576
const JUMP_BOOST_ACCELERATION = -294
const JUMP_LAUNCH_VELOCITY = -185
const MAX_RUN_SPEED = 90
const MAX_FALL_SPEED = 220
const CAYOTE_TIME_SECS = 0.1
const PREGROUND_JUMP_TIME_SECS = 0.1


func _ready():
	#spawn()
	pass

func spawn():
	_is_alive = true
	_direction_x = 1
	global_position = (map as GameMap).player_spawn_point.global_position

func _process(_delta):
	if _is_alive:
		_input_direction = int(Input.get_axis("ui_left", "ui_right"))
	else:
		_input_direction = 0
		
	if _input_direction:
		_direction_x = _input_direction

	# Set animation
	animated_sprite.flip_h = _direction_x < 0
	if is_on_floor():
		if abs(velocity.x) < 1 and !_input_direction:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("run")
	else:
		animated_sprite.play("jump")

func _physics_process(delta):
	# Apply gravity
	if is_on_floor():
		_cayote_time_remaining = CAYOTE_TIME_SECS
	else:
		velocity.y += GRAVITY_ACCELERATION * delta
		if _cayote_time_remaining > 0:
			_cayote_time_remaining -= delta
	
	# Handle jump
	if _is_alive:
		if Input.is_action_just_pressed("jump") and _cayote_time_remaining > 0:
			velocity.y = JUMP_LAUNCH_VELOCITY
		if Input.is_action_pressed("jump") and velocity.y < 0:
			velocity.y += JUMP_BOOST_ACCELERATION * delta

	# Handle running
	if _input_direction:
		var acceleration: float = GROUND_ACCELERATION if is_on_floor() else AIR_ACCELERATION
		velocity.x += _input_direction * acceleration * delta
	else:
		if is_on_floor():
			velocity.x = move_toward(velocity.x, 0, GROUND_ACCELERATION * delta)
	
	# Limit velocity
	velocity.x = clamp(velocity.x, -MAX_RUN_SPEED, MAX_RUN_SPEED)
	if velocity.y > MAX_FALL_SPEED:
		velocity.y = MAX_FALL_SPEED

	move_and_slide()


func _on_safe_area_body_exited(body: Node2D):
	if body.name == "Player":
		_is_alive = false
		death_timer.start()


func _on_death_timer_timeout():
	player_died.emit()


func _on_hud_done_fading_out():
	spawn()
