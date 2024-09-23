extends TileMap
class_name GameMap

@export var room_size_in_tiles: int
@export var player_spawn_point: Marker2D
@export var safe_area: Area2D
@export var rain_particles: GPUParticles2D


func _ready():
	set_safe_area()

func set_safe_area() -> void:
	var used_rect_in_tiles: Rect2 = get_used_rect()
	var tile_size: Vector2 = tile_set.tile_size
	var used_rect: Rect2 = Rect2(global_position + used_rect_in_tiles.position * tile_size, used_rect_in_tiles.size * tile_size)
	var room_size: int = int(tile_size.x * room_size_in_tiles)
	
	var left: float = floor(used_rect.position.x / room_size) * room_size
	var right: float = ceil((used_rect.position.x + used_rect.size.x) / room_size) * room_size
	var top: float = floor(used_rect.position.y / room_size) * room_size
	var bottom: float = ceil((used_rect.position.y + used_rect.size.y) / room_size) * room_size
	
	var rectangle = RectangleShape2D.new()
	rectangle.size = Vector2(right - left, bottom - top)
	
	var collision_shape: CollisionShape2D = CollisionShape2D.new()
	collision_shape.shape = rectangle
	#safe_area.add_child(collision_shape)
	
	#print(safe_area.global_position)
	#print(collision_shape.shape.get_rect().position + safe_area.global_position)


func _on_player_player_died():
	rain_particles.restart()
