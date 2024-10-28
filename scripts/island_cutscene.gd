extends Node2D

@export var animator: AnimationPlayer
@export var scene_resource: SceneResource


func _ready() -> void:
	if GlobalData.is_game_ended:
		animator.play('outro')
	else:
		animator.play('intro')

		
func _input(_event):
	if Input.is_action_pressed("ui_cancel"):
		exit_game()

		
func switch_to_gameplay_scene():
	var scene_tree: SceneTree = get_tree()
	scene_tree.change_scene_to_file(scene_resource.gameplay_scene_path)
	
	
func exit_game():
	get_tree().quit()
