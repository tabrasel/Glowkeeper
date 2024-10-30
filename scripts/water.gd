class_name Water
extends Node2D

@onready var map: TileMap = %TileMap
@onready var camera: Camera2D = %Camera

@export var bounds_shape: CollisionShape2D
@export var visible_poly: Polygon2D
@export var points_per_tile: int

@export var spring_strength: float
@export var spring_damping: float
@export var spread: int

@export var ripple_timer: Timer
@export var ripple_velocity: float

@export var splash_audio_player: AudioStreamPlayer

var _surface_points: Array[WaterSurfacePoint] = []
var _map_tile_size: Vector2
var _dist_between_points: float


class WaterSurfacePoint:
	var position: Vector2
	var velocity: Vector2

	func _init(pos: Vector2):
		self.position = pos


func _ready() -> void:
	var bounds_rect: Rect2 = bounds_shape.shape.get_rect()
	_map_tile_size = map.tile_set.tile_size
	var tile_count: int = int(bounds_rect.size.x / _map_tile_size.x) + 1
	var point_count: int = tile_count * points_per_tile - (tile_count - 1)
	_dist_between_points = _map_tile_size.x / (points_per_tile - 1)
	
	var x: float = 0
	for i in range(0, point_count, 1):
		var point_position: Vector2 = Vector2(x, 0)
		var point: WaterSurfacePoint = WaterSurfacePoint.new(point_position)
		_surface_points.append(point)
		x += _dist_between_points
	
	var poly_points: PackedVector2Array = []
	for i: int in range(_surface_points.size()):
		var point: WaterSurfacePoint = _surface_points[i]
		poly_points.append(point.position)
	poly_points.append(Vector2(_surface_points[_surface_points.size() - 1].position.x, _map_tile_size.y))
	poly_points.append(Vector2(0, _map_tile_size.y))
	visible_poly.polygon = poly_points


func _process(delta: float) -> void:
	for i in range(spread):
		for j in range(_surface_points.size()):
			var point: WaterSurfacePoint = _surface_points[j]
			
			if j != 0 and j != _surface_points.size() - 1:
				# Spring towards base water surface height
				var base_dist: float = 0 - point.position.y
				point.velocity.y += base_dist * spring_strength
				
				# Spring towards left point
				if j > 0:
					var left_point: WaterSurfacePoint = _surface_points[j - 1]
					var left_dist: float = left_point.position.y - point.position.y
					point.velocity.y += left_dist * spring_strength 
				
				# Spring towards right point
				if j < _surface_points.size() - 1:
					var right_point: WaterSurfacePoint = _surface_points[j + 1]
					var right_dist: float = right_point.position.y - point.position.y
					point.velocity.y += right_dist * spring_strength 
				
				point.velocity += -point.velocity * spring_damping
				point.position += point.velocity * delta
				
				if point.position.y > _map_tile_size.y:
					point.position.y = _map_tile_size.y
			
			visible_poly.polygon[j].y = point.position.y


func _on_ripple_timer_timeout() -> void:
	"""
	Make several ripples offscreen
	"""
	var offset_min: float = (175.0 / 2) + 25
	var offset_max: float = (350.0 / 2) + 25
	
	for i in range(3):
		var offset: float = randf_range(offset_min, offset_max)
		var ripple_x: float = camera.global_position.x - offset
		_make_ripple(ripple_x, randf_range(5, 25) * (1 if randf() < 0.5 else -1))
	
	for i in range(3):
		var offset: float = randf_range(offset_min, offset_max)
		var ripple_x: float = camera.global_position.x + offset
		_make_ripple(ripple_x, randf_range(5, 25) * (1 if randf() < 0.5 else -1))
	
	ripple_timer.wait_time = randf_range(0.25, 2)


func _on_area_2d_body_entered(body: Node) -> void:
	if body is Player:
		_make_ripple(body.global_position.x, 20)
		splash_audio_player.play()

func _on_area_2d_body_exited(body: Node) -> void:
	if body is Player:
		var player = body as Player
		if player.is_alive:
			_make_ripple(body.global_position.x, -20)
			splash_audio_player.play()


func _make_ripple(x: float, velocity: float) -> void:
	var surface_point: WaterSurfacePoint = _get_closest_surface_point(x)
	surface_point.velocity.y = velocity
	

func _get_closest_surface_point(x: float) -> WaterSurfacePoint:
	var body_offset: float = x - global_position.x
	var point_index: int = roundi(body_offset / _dist_between_points)
	if point_index <= 0:
		point_index = 1
	elif point_index >= _surface_points.size() - 1:
		point_index = _surface_points.size() - 2
	return _surface_points[point_index]
