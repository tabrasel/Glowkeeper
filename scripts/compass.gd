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
	var center: Vector2i = Vector2.ZERO
	var north: Vector2i = Vector2i(int(cos(_angle) * 7), int(sin(_angle) * 7))
	var south: Vector2 = Vector2i(int(-north.x), int(-north.y))

	var north_color = Color(1, 0, 0) if _state == CompassState.POINTING else Color(1, 1, 1) 

	_draw_segment(north, north_color)
	_draw_segment(south, Color.WHITE)

func _on_fireflies_deposited():
	_angle_velocity = 0.3 * _next_spin_dir
	_target_firefly = null
	spin_timer.start()
	_next_spin_dir *= -1

func _on_spin_timer_timeout():
	choose_target()
	
	
func _draw_segment(target: Vector2i, line_color: Color):
	if target.x == 0 || target.y == 0:
		# draw a single straight line
		draw_line(Vector2.ZERO, target, line_color)
	elif abs(target.x) > abs(target.y):
		_draw_horizontal_segments(target, line_color)
	else:
		_draw_vertical_segments(target, line_color)
	

func _draw_horizontal_segments(target: Vector2, line_color: Color):
	# should be negative ONLY if target.x is negative
	var width = abs(target.x / target.y) * sign(target.x)

	var float_x := 0.0

	var sign_y = sign(target.y)
	for int_y in abs(target.y):
		# make y negative if required
		var y: int = int_y * sign_y
		# only convert to int when drawing
		var ax := int(float_x)
		var bx := int(float_x + width)

		var a := Vector2(ax, y)
		var b := Vector2(bx, y)
		draw_line(a, b, line_color)

		float_x += width


func _draw_vertical_segments(target: Vector2, line_color: Color):
	# should be negative ONLY if target.y is negative
	var height = abs(target.y / target.x) * sign(target.y)

	var float_y := 0.0

	var sign_x = sign(target.x)
	for int_x in abs(target.x):
		# make x negative if required
		var x: int = int_x * sign_x
		# only convert to int when drawing
		var ay := int(float_y)
		var by := int(float_y + height)

		var a := Vector2(x, ay)
		var b := Vector2(x, by)
		draw_line(a, b, line_color)

		float_y += height
