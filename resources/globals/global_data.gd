extends Node

var paused = false
var time_over = false

var slow_down_factor:float = 1.0
var slow_down_list = []

func _process(delta: float) -> void:
	if slow_down_list:
		slow_down_factor = 0.2
	else:
		slow_down_factor = 1.0
