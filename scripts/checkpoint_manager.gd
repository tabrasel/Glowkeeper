class_name CheckpointManager
extends Node2D

var current_active_checkpoint: Checkpoint


func _ready():
	var checkpoint_nodes = get_tree().get_nodes_in_group("Checkpoints")
	for node in checkpoint_nodes:
		if node is Checkpoint:
			var checkpoint: Checkpoint = node as Checkpoint
			checkpoint.connect("activated", _on_checkpoint_activated)


func _on_checkpoint_activated(checkpoint: Checkpoint):
	if current_active_checkpoint and checkpoint != current_active_checkpoint:
		current_active_checkpoint.deactivate()
	current_active_checkpoint = checkpoint
