extends Node2D

@export var animator: AnimationPlayer
@export var scene_resource: SceneResource
@export var stat_values_label: Label


func _ready() -> void:
	if GlobalData.is_game_ended:
		animator.play('outro')
		
		var gameplay_mins: int = int(GlobalData.gameplay_timer_secs / 60)
		var gameplay_secs: int = int(GlobalData.gameplay_timer_secs) % 60
		stat_values_label.text = '%02d:%02d' % [gameplay_mins, gameplay_secs] + '\n' + str(GlobalData.death_count)
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
