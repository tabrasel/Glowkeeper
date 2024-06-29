extends Control
class_name HUD

@export var transition_display: ColorRect
@export var transition_speed: float
@export var inter_transition_timer: Timer

@export var firefly_resource: FireflyResource
@export var firefly_count_label: Label

var _is_fading_out: bool
var _is_fading_in: bool

signal done_fading_out


func _process(delta):
	if _is_fading_out:
		fade_out(delta)
	elif _is_fading_in:
		fade_in(delta)
	
	firefly_count_label.text = str(firefly_resource.deposited_fireflies.size()) + "/20"


func fade_out(delta: float):
	if transition_display.color.a < 1:
		transition_display.color.a += transition_speed * delta
	if transition_display.color.a >= 1:
		_is_fading_out = false
		inter_transition_timer.start()
		done_fading_out.emit()


func fade_in(delta: float):
	if transition_display.color.a > 0:
		transition_display.color.a -= transition_speed * delta
	if transition_display.color.a <= 0:
		_is_fading_in = false


func _on_player_player_died():
	_is_fading_out = true


func _on_inter_transition_timer_timeout():
	_is_fading_in = true
