extends Node
class_name GameManager


func _input(_event):
	if Input.is_action_pressed("ui_cancel"):
		var viewport = get_viewport()
		var img = Image.new()
		img = viewport.get_texture().get_image()
		var file_path = "user://screenshot.png"
		var _error = img.save_png(file_path)
	
		get_tree().quit()
