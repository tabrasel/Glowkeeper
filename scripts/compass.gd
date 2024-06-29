extends Node2D
class_name Compass

@export var spring_strength: float
@export var spring_damping: float
@export var spin_timer: Timer
@export var firefly_resource: FireflyResource

var _target_firefly: Firefly
var _angle_velocity: float
var _angle: float


func _ready():
	var fireflies: Array[Node] = get_tree().get_nodes_in_group("Fireflies")
	firefly_resource.set_uncaught_fireflies(fireflies)
	choose_target()
	
	firefly_resource.connect("fireflies_deposited", _on_fireflies_deposited)

func _process(delta):
	if _target_firefly:
		var direction_to_fly: Vector2 = (_target_firefly.global_position - global_position).normalized()
		var angle_to_fly: float = direction_to_fly.angle()
		var angle_diff: float = angle_difference(_angle, angle_to_fly)	
		_angle_velocity += (angle_diff * delta * spring_strength) - (spring_damping * _angle_velocity)
	
	_angle += _angle_velocity
	
	queue_redraw()

func choose_target():
	_target_firefly = firefly_resource.get_next_firefly()

func _draw():
	var center: Vector2 = Vector2.ZERO
	var north: Vector2 = Vector2(cos(_angle) * 3, sin(_angle) * 3)
	var south: Vector2 = Vector2(-north.x, -north.y)

	draw_line(center, north, Color(1, 0, 0))
	draw_line(center, south, Color(1, 1, 1))

func _on_fireflies_deposited():
	_angle_velocity = 0.3 if randf_range(0, 1) < 0.5 else -0.3
	_target_firefly = null
	spin_timer.start()

func _on_spin_timer_timeout():
	choose_target()
