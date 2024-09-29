extends Resource
class_name FireflyResource

var uncaught_fireflies: Array = []
var caught_fireflies: Array = []
var deposited_fireflies: Array = []

signal firefly_caught()
signal fireflies_deposited()
signal all_fireflies_deposited()


func set_uncaught_fireflies(uncaught_fireflies: Array):
	self.uncaught_fireflies = uncaught_fireflies

func get_next_firefly() -> Node:
	if uncaught_fireflies.size() == 0:
		return deposited_fireflies[0]
	return uncaught_fireflies[0]

func catch_firefly(firefly: Firefly):
	uncaught_fireflies.erase(firefly)
	caught_fireflies.append(firefly)
	firefly_caught.emit()

func deposit_fireflies():
	for i in range(caught_fireflies.size() - 1, -1, -1):
		var firefly: Firefly = caught_fireflies[i]
		caught_fireflies.remove_at(i)
		deposited_fireflies.append(firefly)
		firefly.deposit()
		
	fireflies_deposited.emit()
	
	if len(deposited_fireflies) >= 20:
		all_fireflies_deposited.emit()
