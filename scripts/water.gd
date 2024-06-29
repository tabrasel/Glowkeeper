extends Node2D

@onready var player = %Player
@onready var map = %TileMap

@export var bounds_shape: CollisionShape2D
@export var visible_poly: Polygon2D
@export var points_per_tile: int
@export var spring_strength: float
@export var spring_damping: float

var _surfacePoints: Array[WaterSurfacePoint] = []


class WaterSurfacePoint:
	var position: Vector2
	var velocity: Vector2

	func _init(position: Vector2):
		self.position = position
		velocity = Vector2.ZERO


func _ready():
	var bounds_rect: Rect2 = bounds_shape.shape.get_rect()
	var map_tile_size: Vector2 = map.tile_set.tile_size
	var tile_count: int = int(bounds_rect.size.x / map_tile_size.x)
	var point_count: int = tile_count * points_per_tile - (tile_count - 1)
	
	var x: float = 0
	for i in range(0, point_count, 1):
		var pointPosition: Vector2 = Vector2(x, bounds_rect.position.y - bounds_rect.size.y + randf_range(0, 3))
		var point: WaterSurfacePoint = WaterSurfacePoint.new(pointPosition)
		_surfacePoints.append(point)
		visible_poly.polygon.append(pointPosition)
		x += map_tile_size.x / (points_per_tile - 1)
	
	var p = visible_poly.polygon
	for point in _surfacePoints:
		p.append(point.position)
	visible_poly.polygon = p

func _process(_delta):
	#print(_surfacePoints.size())
	for i in range(_surfacePoints.size()):
		visible_poly.polygon[i].y = randf_range(-3, 3)
