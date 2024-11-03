class_name HUD
extends Control

@export var animation_player: AnimationPlayer
@export var transition_display: ColorRect
@export var letterbox: Control
@export var room_title_label: Label
@export var firefly_resource: FireflyResource


func _ready():
	var room_nodes = get_tree().get_nodes_in_group("Rooms")
	for node in room_nodes:
		if node is RoomArea:
			var room_area: RoomArea = node as RoomArea
			room_area.connect("room_entered", _on_room_entered)


func _on_room_entered(room_area: RoomArea):
	room_title_label.text = room_area.title


func _on_player_player_died():
	animation_player.play('reset')


func _on_game_manager_game_completed():
	animation_player.play('enter_cutscene_mode')
