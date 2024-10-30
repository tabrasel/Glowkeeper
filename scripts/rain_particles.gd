class_name Rain
extends GPUParticles2D

@onready var player: Player = %Player


func _process(_delta):
	global_position.x = player.global_position.x
