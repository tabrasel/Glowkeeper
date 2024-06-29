extends AnimatedSprite2D
class_name FireflyCatchExplosion


func _on_animation_finished():
	queue_free()
