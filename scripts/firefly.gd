extends CharacterBody2D
class_name Firefly

@export var animated_sprite: AnimatedSprite2D
@export var catch_explosion_scene: PackedScene
@export var firefly_resource: FireflyResource

var player: Node2D
var lantern: Lantern

var _target_position = Vector2()
var _target_offset = Vector2()
var _max_distance = randf_range(10, 18)
var _springiness = randf_range(0.03, 0.12)
var _is_caught = false
var _is_deposited = false
var _retarget_time_remaining: float

const CATCH_DISTANCE = 15
const TARGET_DISTANCE = 10
const DAMPING = 0.98


func _ready():
	player = get_node("%Player")
	lantern = get_node("%Lantern")
	
	_target_position.x = global_position.x
	_target_position.y = global_position.y
	update_target()

func _physics_process(delta):
	if !_is_caught and !_is_deposited and position.distance_to(player.position) <= CATCH_DISTANCE:
		catch()
	
	_retarget_time_remaining -= delta
	if _retarget_time_remaining <= 0:
		update_target()
		_retarget_time_remaining = randf_range(0.5, 1)
	
	if _is_caught:
		_target_position = player.position
	
	if _is_deposited:
		_target_position = lantern.top_marker.global_position
	
	if position.distance_to(_target_position) > TARGET_DISTANCE:
		velocity += ((_target_position + _target_offset) - position) * _springiness
	else:
		velocity -= ((_target_position + _target_offset) - position) * _springiness * 4
	velocity *= DAMPING

	move_and_slide()
	
	animated_sprite.flip_h = velocity.x < 0

func catch():
	_is_caught = true
	firefly_resource.catch_firefly(self)
	
	var catch_explosion = catch_explosion_scene.instantiate()
	add_child(catch_explosion)
	catch_explosion.global_position = global_position

func update_target():
	_target_offset.x = randf_range(-8, 8)
	_target_offset.y = randf_range(-8, 8)

func deposit():
	_is_caught = false
	_is_deposited = true
