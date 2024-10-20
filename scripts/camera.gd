class_name GameplayCamera
extends Camera2D

@export var map_bounds_area_shape: CollisionShape2D
@export var room_collision_area: Area2D

@onready var player = %Player

var view_size: Vector2
var map_bounds_rect: Rect2

var _map_bounds_left: float
var _map_bounds_right: float
var _map_bounds_top: float
var _map_bounds_bottom: float
var _is_shaking: bool

func _ready():
	view_size = get_viewport_rect().size
	map_bounds_rect = map_bounds_area_shape.shape.get_rect()
	
	_map_bounds_left = map_bounds_area_shape.global_position.x - map_bounds_rect.size.x / 2
	_map_bounds_right = map_bounds_area_shape.global_position.x + map_bounds_rect.size.x / 2
	_map_bounds_top = map_bounds_area_shape.global_position.y - map_bounds_rect.size.y / 2
	_map_bounds_bottom = map_bounds_area_shape.global_position.y + map_bounds_rect.size.y / 2
	

func _process(_delta):
	if player.is_alive:
		var target_position: Vector2 = player.position
		
		if target_position.x <= _map_bounds_left:
			target_position.x = _map_bounds_left
		elif target_position.x >= _map_bounds_right:
			target_position.x = _map_bounds_right - 1
			
		if target_position.y <= _map_bounds_top:
			target_position.y = _map_bounds_top
		elif target_position.y >= _map_bounds_bottom:
			target_position.y = _map_bounds_bottom - 1
	
		var col: int = floor(target_position.x / view_size.x)
		var row: int = floor(target_position.y / view_size.y)

		position.x = ceil(view_size.x / 2) + view_size.x * col
		position.y = ceil(view_size.y / 2) + view_size.y * row

		if _is_shaking:
			position.x += randi_range(-1, 1)
			position.y += randi_range(-1, 1)
	
func start_shaking():
	_is_shaking = true
