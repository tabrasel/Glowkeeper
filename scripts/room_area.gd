class_name RoomArea
extends Area2D

@export var title: String

@onready var camera: GameplayCamera = %Camera

signal room_entered(room_area)

var _camera_is_in_room: bool


func _on_body_entered(body):
	#print(body)
	pass


func _on_area_shape_entered(area_rid, area, area_shape_index, local_shape_index):
	if area_rid == camera.collision_area.get_rid():
		room_entered.emit(self)
		print('entered room: ' + title)
