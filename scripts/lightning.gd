class_name Lightning
extends Node2D

@export var strike_sprite: AnimatedSprite2D
@export var strike_timer: Timer
@export var strike_area_shape: CollisionShape2D

var _strike_area_rect: Rect2
var _strike_animation_names: PackedStringArray
var _next_animation_name: String

func _ready():
	_strike_area_rect = strike_area_shape.shape.get_rect()
	_strike_animation_names = strike_sprite.sprite_frames.get_animation_names()
	_reset()
	
func _reset():
	_next_animation_name = _strike_animation_names[randi() % _strike_animation_names.size()]
	strike_timer.wait_time = randf_range(4, 6)
	position.x = randf_range(0, _strike_area_rect.size.x)

func _on_strike_timer_timeout():
	strike_sprite.play(_next_animation_name)

func _on_strike_animation_finished():
	_reset()
