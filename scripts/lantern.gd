extends Node2D
class_name Lantern

@export var top_marker: Marker2D
@export var deposit_area: Area2D
@export var deposit_sign_sprite: AnimatedSprite2D
@export var firefly_resource: FireflyResource
@export var deposit_audio_player: AudioStreamPlayer

@export_group('Firefly Count')
@export var firefly_count_group: Control
@export var firefly_count_foreground_label: Label
@export var firefly_count_background_label: Label
@export var firefly_count_fade_speed: float

var _player_is_in_deposit_area: bool


func set_deposit_sign_active(active: bool):
	if active:
		deposit_sign_sprite.play("flash")
	else:
		deposit_sign_sprite.play("idle")

func _ready():
	firefly_resource.connect("firefly_caught", _on_firefly_caught)
	firefly_resource.connect("fireflies_deposited", _on_fireflies_deposited)

func _process(delta):
	if Input.is_action_just_pressed("ui_down") and _player_is_in_deposit_area and firefly_resource.caught_fireflies.size() > 0:
		firefly_resource.deposit_fireflies()
	
	_update_firefly_count(delta)
	
	
func _update_firefly_count(delta):
	var alpha_velocity = firefly_count_fade_speed if _player_is_in_deposit_area else -firefly_count_fade_speed
	var alpha = clamp(firefly_count_group.modulate.a + alpha_velocity * delta, 0, 1)
	firefly_count_group.modulate = Color(1, 1, 1, alpha)
	
	var firefly_count_label_text: String =  str(firefly_resource.deposited_fireflies.size()) + "/20"
	firefly_count_foreground_label.text = firefly_count_label_text
	firefly_count_background_label.text = firefly_count_label_text
	

func _on_firefly_caught():
	set_deposit_sign_active(true)

func _on_fireflies_deposited():
	set_deposit_sign_active(false)
	deposit_audio_player.play()

func _on_deposit_area_body_entered(body):
	if body.name == "Player":
		_player_is_in_deposit_area = true

func _on_deposit_area_body_exited(body):
	if body.name == "Player":
		_player_is_in_deposit_area = false
