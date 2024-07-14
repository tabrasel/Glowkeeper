class_name HUD
extends Control

@export var animation_player: AnimationPlayer
@export var transition_display: ColorRect

@export var firefly_resource: FireflyResource
@export var firefly_count_label: Label


func _process(delta):
	firefly_count_label.text = str(firefly_resource.deposited_fireflies.size()) + "/20"


func _on_player_player_died():
	animation_player.play("reset")
