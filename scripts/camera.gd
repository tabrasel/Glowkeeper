extends Camera2D


@onready var player = %Player
@onready var safe_area_collision_shape: CollisionShape2D = %SafeAreaCollisionShape2D

var view_size: Vector2
var limit_rect: Rect2

var _is_shaking: bool

func _ready():
	view_size = get_viewport_rect().size
	limit_rect = safe_area_collision_shape.shape.get_rect()

func _process(_delta):
	if player.is_alive:
		var target_position = player.position
		target_position = target_position.clamp(limit_rect.position, limit_rect.position + limit_rect.size)
		
		position.x = floor(target_position.x / view_size.x) * view_size.x + view_size.x / 2
		position.y = floor(target_position.y / view_size.y) * view_size.y + view_size.y / 2

		if _is_shaking:
			position.x += randi_range(-1, 1)
			position.y += randi_range(-1, 1)
	
func start_shaking():
	_is_shaking = true
