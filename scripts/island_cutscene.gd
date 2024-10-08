extends Node2D

@export var animator: AnimationPlayer
@export var gameplay_scene: PackedScene


func _input(_event):
	if Input.is_action_pressed("ui_cancel"):
		exit_game()

func switch_to_gameplay_scene():
	var scene_tree: SceneTree = get_tree()
	scene_tree.change_scene_to_packed(gameplay_scene)
	
func exit_game():
	get_tree().quit()
