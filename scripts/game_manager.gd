extends Node
class_name GameManager

@export var firefly_resource: FireflyResource
@export var scene_resource: SceneResource
@export var animator: AnimationPlayer

signal game_completed()


func switch_to_ending_scene():
	var scene_tree: SceneTree = get_tree()
	scene_tree.change_scene_to_file(scene_resource.cutscene_scene_path)


func _ready():
	firefly_resource.connect("all_fireflies_deposited", _on_all_fireflies_deposited)


func _input(_event):
	if Input.is_action_pressed("ui_cancel"):
		var viewport = get_viewport()
		var img = Image.new()
		img = viewport.get_texture().get_image()
		var file_path = "user://screenshot.png"
		var _error = img.save_png(file_path)
	
		get_tree().quit()


func _on_all_fireflies_deposited():
	GlobalData.is_game_ended = true
	game_completed.emit()
	animator.play('ending')
