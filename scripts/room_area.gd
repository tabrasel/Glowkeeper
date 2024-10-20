class_name RoomArea
extends Area2D

@export var title: String

@onready var camera: GameplayCamera = %Camera

signal room_entered(room_area)


func _on_area_shape_entered(area_rid, area, area_shape_index, local_shape_index):
	if area_rid == camera.room_collision_area.get_rid():
		room_entered.emit(self)
