extends Node2D
class_name Compass

enum CompassState {IDLE, SPINNING, POINTING}

@export var spring_strength: float
@export var spring_damping: float
@export var spin_timer: Timer
@export var firefly_resource: FireflyResource

var _state: CompassState = CompassState.POINTING
var _target_firefly: Firefly
var _angle_velocity: float
var _angle: float
var _next_spin_dir: int = 1


func choose_target():
	_target_firefly = firefly_resource.get_next_firefly()

func start_idle_state():
	_state = CompassState.IDLE
	
	
func start_spinning_state():
	_state = CompassState.SPINNING

func start_pointing_state():
	_state = CompassState.POINTING

func _ready():
	var fireflies: Array[Node] = get_tree().get_nodes_in_group("Fireflies")
	firefly_resource.set_uncaught_fireflies(fireflies)
	choose_target()
	
	firefly_resource.connect("fireflies_deposited", _on_fireflies_deposited)

func _process(delta):
	if _state == CompassState.IDLE:
		_angle_velocity += -_angle_velocity * 0.05
	if _state == CompassState.SPINNING:
		_angle_velocity += 0.3 * delta
	elif _state == CompassState.POINTING:
		if _target_firefly:
			var direction_to_fly: Vector2 = (_target_firefly.global_position - global_position).normalized()
			var angle_to_fly: float = direction_to_fly.angle()
			var angle_diff: float = angle_difference(_angle, angle_to_fly)	
			_angle_velocity += (angle_diff * delta * spring_strength) - (spring_damping * _angle_velocity)
	
	_angle_velocity = clamp(_angle_velocity, -500, 500)
	_angle += _angle_velocity
	
	queue_redraw()

func _draw():
	var center: Vector2 = Vector2.ZERO
	var north: Vector2 = Vector2(cos(_angle) * 3, sin(_angle) * 3)
	var south: Vector2 = Vector2(-north.x, -north.y)

	var north_color = Color(1, 0, 0) if _state == CompassState.POINTING else Color(1, 1, 1) 
	draw_line(center, north, north_color)
	draw_line(center, south, Color(1, 1, 1))

func _on_fireflies_deposited():
	_angle_velocity = 0.3 * _next_spin_dir
	_target_firefly = null
	spin_timer.start()
	_next_spin_dir *= -1

func _on_spin_timer_timeout():
	choose_target()

