class_name HUD
extends Control

@export var animation_player: AnimationPlayer
@export var transition_display: ColorRect
@export var letterbox: Control

@export var firefly_resource: FireflyResource


func _ready():
	letterbox.visible = false

func _on_player_player_died():
	animation_player.play('reset')

func _on_game_manager_game_completed():
	animation_player.play('enter_cutscene_mode')
