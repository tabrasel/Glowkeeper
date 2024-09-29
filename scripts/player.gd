extends CharacterBody2D
class_name Player

@export var animated_sprite: AnimatedSprite2D
@export var collider: CollisionShape2D
@export var death_timer: Timer

@export_group('Audio Players')
@export var footstep_audio_player: AudioStreamPlayer
@export var jump_audio_player: AudioStreamPlayer
@export var land_audio_player: AudioStreamPlayer
@export var head_hit_audio_player: AudioStreamPlayer

@onready var map: TileMap = %TileMap

signal player_died

var _input_direction: int
var _direction_x: int = 1
var _cayote_time_remaining: float
var _jump_buffer_time_remaining: float
var _was_on_floor: bool
var _was_on_ceiling: bool

var is_alive: bool = true
var _is_controllable: bool = true

const GROUND_ACCELERATION = 780
const AIR_ACCELERATION = 600
const GRAVITY_ACCELERATION = 576
const JUMP_BOOST_ACCELERATION = -294
const JUMP_LAUNCH_VELOCITY = -185
const MAX_RUN_SPEED = 90
const MAX_FALL_SPEED = 220
const CAYOTE_TIME_SECS = 0.1
const JUMP_BUFFER_SECS = 0.07


func _ready():
	spawn()

func spawn():
	is_alive = true
	_is_controllable = true
	
	_direction_x = 1
	global_position = (map as GameMap).player_spawn_point.global_position

func _process(_delta):
	if _is_controllable:
		_input_direction = int(Input.get_axis("ui_left", "ui_right"))
	else:
		_input_direction = 0
		
	if _input_direction:
		_direction_x = _input_direction

	# Set animation
	animated_sprite.flip_h = _direction_x < 0
	if is_on_floor():
		if !_was_on_floor:
			land_audio_player.play()
		if abs(velocity.x) < 1 and !_input_direction:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("run")
			if (!footstep_audio_player.playing):
				footstep_audio_player.play()
	else:
		animated_sprite.play("jump")
		
	if is_on_ceiling() and !_was_on_ceiling:
			head_hit_audio_player.play()


func jump() -> void:
	velocity.y = JUMP_LAUNCH_VELOCITY
	_jump_buffer_time_remaining = 0
	_cayote_time_remaining = 0
	jump_audio_player.play(0.1)


func _physics_process(delta):
	# Apply gravity
	if not is_on_floor():
		velocity.y += GRAVITY_ACCELERATION * delta

	if _is_controllable:
		_handle_input(delta)
	else:
		if is_on_floor():
			velocity.x = move_toward(velocity.x, 0, GROUND_ACCELERATION * delta)
	
	# Limit velocity
	velocity.x = clamp(velocity.x, -MAX_RUN_SPEED, MAX_RUN_SPEED)
	if velocity.y > MAX_FALL_SPEED:
		velocity.y = MAX_FALL_SPEED

	_was_on_floor = is_on_floor()
	_was_on_ceiling = is_on_ceiling()

	move_and_slide()


func _handle_input(delta):
	# Handle running
	if _input_direction:
		var acceleration: float = GROUND_ACCELERATION if is_on_floor() else AIR_ACCELERATION
		velocity.x += _input_direction * acceleration * delta
	else:
		if is_on_floor():
			velocity.x = move_toward(velocity.x, 0, GROUND_ACCELERATION * delta)
	
	if is_on_floor():
		_cayote_time_remaining = CAYOTE_TIME_SECS
	else:
		if _cayote_time_remaining > 0:
			_cayote_time_remaining -= delta
		if _jump_buffer_time_remaining > 0:
			_jump_buffer_time_remaining -= delta
	
	# Handle jumping
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			jump()
		else:
			if _cayote_time_remaining > 0:
				jump()
			else:
				_jump_buffer_time_remaining = JUMP_BUFFER_SECS
	
	if Input.is_action_pressed("jump"):
		if is_on_floor() and _jump_buffer_time_remaining > 0:
			jump()
		if velocity.y < 0:
			velocity.y += JUMP_BOOST_ACCELERATION * delta		


func _on_safe_area_body_exited(body: Node2D):
	if body.name == "Player":
		is_alive = false
		_is_controllable = false
		death_timer.start()


func _on_death_timer_timeout():
	player_died.emit()


func _on_hud_done_fading_out():
	spawn()


func _on_game_manager_game_completed():
	_is_controllable = false
