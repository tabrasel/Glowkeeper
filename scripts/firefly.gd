extends CharacterBody2D
class_name Firefly

enum FireflyState {ROAMING, CAUGHT, DEPOSITED}

@export var animated_sprite: AnimatedSprite2D
@export var catch_explosion_scene: PackedScene
@export var firefly_resource: FireflyResource

@export var angle_spring_strength: float
@export var angle_spring_strength_range: float
@export var angle_spring_damping: float
@export var angle_spring_damping_range: float
@export var acceleration: float
@export var acceleration_range: float
@export var speed_range: float

var _player: Node2D
var _lantern: Lantern

var _angle: float
var _angle_velocity: float

var _target_anchor = Vector2()
var _target_offset = Vector2()
var _target_position = Vector2()

var state: FireflyState = FireflyState.ROAMING

const CATCH_DISTANCE = 15


func _ready():
	_player = get_node("%Player")
	_lantern = get_node("%Lantern")
	
	angle_spring_strength += angle_spring_strength_range * randf_range(-1, 1)
	angle_spring_damping += angle_spring_damping_range * randf_range(-1, 1)
	acceleration += acceleration_range * randf_range(-1, 1)
	
	_target_anchor.x = global_position.x
	_target_anchor.y = global_position.y
	_update_target()

func _physics_process(delta: float):
	if state == FireflyState.ROAMING:
		if global_position.distance_to(_player.global_position) <= CATCH_DISTANCE:
			_catch()
	elif state == FireflyState.CAUGHT:
		_target_anchor = _player.global_position
	
	_target_position = _target_anchor + _target_offset
	var direction_to_target: Vector2 = (_target_position - global_position).normalized()
	var angle_to_target: float = direction_to_target.angle()
	var angle_diff: float = angle_difference(_angle, angle_to_target)
	_angle_velocity += (angle_diff * angle_spring_strength) - (_angle_velocity * angle_spring_damping)
	_angle += _angle_velocity * delta
	
	velocity.x += cos(_angle) * acceleration * delta
	velocity.y += sin(_angle) * acceleration * delta
	
	var dist_to_target: float = global_position.distance_to(_target_position)
	var friction_coef: float = clamp(0.2 - dist_to_target * 0.005, 0.01, 0.06)
	velocity -= velocity * friction_coef
	velocity = velocity.limit_length(150)

	move_and_slide()
	
	animated_sprite.flip_h = velocity.x < 0

func _catch():
	state = FireflyState.CAUGHT
	firefly_resource.catch_firefly(self)
	
	var catch_explosion = catch_explosion_scene.instantiate()
	add_child(catch_explosion)
	catch_explosion.global_position = global_position

func deposit():
	state = FireflyState.DEPOSITED
	_target_position = _lantern.top_marker.global_position

func _update_target():
	_target_offset.x = randf_range(-8, 8)
	_target_offset.y = randf_range(-8, 8)

func _draw():
	var direction_to_target: Vector2 = (_target_position - global_position).normalized()
	#draw_line(Vector2.ZERO, velocity, Color.ORANGE)
	#draw_circle(Vector2.ZERO - Vector2(10, 10), 3, Color.ORANGE)
	pass

func _on_target_reposition_timer_timeout():
	_update_target()
