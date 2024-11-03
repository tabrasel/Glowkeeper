class_name FireflyManager
extends Node2D

@export var firefly_resource: FireflyResource


func release_fireflies() -> void:
	for firefly: Firefly in firefly_resource.uncaught_fireflies:
		firefly.set_state(Firefly.FireflyState.ROAMING)


func arrange_fireflies_around_lantern() -> void:
	var deposited_firefly_count: int = len(firefly_resource.deposited_fireflies)
	for i in range(deposited_firefly_count):
		var firefly: Firefly = firefly_resource.deposited_fireflies[i]
		var angle: float = (float(i) / deposited_firefly_count) * 360
		firefly.arrange_around_lantern(angle)


func move_fireflies_toward_lantern() -> void:
	for i in range(len(firefly_resource.deposited_fireflies)):
		var firefly: Firefly = firefly_resource.deposited_fireflies[i]
		firefly.move_toward_lantern()


func reset_caught_fireflies() -> void:
	for i in range(firefly_resource.caught_fireflies.size() - 1, -1, -1):
		var firefly: Firefly = firefly_resource.caught_fireflies[i]
		firefly.uncatch()
		firefly_resource.caught_fireflies.remove_at(i)
		firefly_resource.uncaught_fireflies.append(firefly)
