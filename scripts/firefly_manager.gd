class_name FireflyManager
extends Node2D

@export var firefly_resource: FireflyResource


func reset_caught_fireflies() -> void:
	for i in range(firefly_resource.caught_fireflies.size() - 1, -1, -1):
		var firefly: Firefly = firefly_resource.caught_fireflies[i]
		firefly.uncatch()
		firefly_resource.caught_fireflies.remove_at(i)
		firefly_resource.uncaught_fireflies.append(firefly)
