extends Node
class_name GameManager

@export var firefly_resource: FireflyResource
@export var animator: AnimationPlayer

signal game_completed()


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
	game_completed.emit()
	animator.play('ending')
