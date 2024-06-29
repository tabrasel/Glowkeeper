extends Node2D
class_name Lantern

@export var top_marker: Marker2D
@export var deposit_area: Area2D
@export var deposit_sign_sprite: AnimatedSprite2D
@export var firefly_resource: FireflyResource

var _player_is_in_deposit_area


func _ready():
	firefly_resource.connect("firefly_caught", _on_firefly_caught)
	firefly_resource.connect("fireflies_deposited", _on_fireflies_deposited)


func _process(_delta):
	if Input.is_action_just_pressed("ui_down") and _player_is_in_deposit_area:
		firefly_resource.deposit_fireflies()

func _on_firefly_caught():
	deposit_sign_sprite.play("flash")

func _on_fireflies_deposited():
	deposit_sign_sprite.play("idle")

func _on_deposit_area_body_entered(body):
	if body.name == "Player":
		_player_is_in_deposit_area = true

func _on_deposit_area_body_exited(body):
	if body.name == "Player":
		_player_is_in_deposit_area = false
