class_name Checkpoint
extends Node2D

@export var lamp_glow: Node2D
@export var lamp_glow_rect: ColorRect
@export var ground_glow: Node2D
@export var ground_glow_sprite: Sprite2D
@export var activation_particles: GPUParticles2D
@export var spawn_point: Node2D
@export var ground_glow_animation_player: AnimationPlayer
@export var lamp_glow_animation_player: AnimationPlayer

signal activated(checkpoint)

var _active: bool = false


func activate():
	_active = true
	activated.emit(self)
	activation_particles.emitting = true
	
	lamp_glow.visible = true
	lamp_glow_animation_player.play("glow")
	
	# Fade out ground glow
	ground_glow_animation_player.pause()
	var ground_glow_tween: Tween = create_tween()
	ground_glow_tween.tween_property(ground_glow, 'modulate', Color(1, 1, 1, 0), 0.1)
	

func deactivate():
	_active = false
	activation_particles.emitting = false
	
	ground_glow.visible = true
	ground_glow_animation_player.play("glow")
	
	lamp_glow_animation_player.pause()
	var lamp_glow_tween: Tween = create_tween()
	lamp_glow_tween.tween_property(lamp_glow, 'modulate', Color(1, 1, 1, 0), 0.2)


func _ready():
	deactivate()


func _on_activation_area_body_entered(body: Node) -> void:
	if _active:
		return
		
	if body is Player:
		activate()
		body.set_spawn_data(spawn_point.global_position)
