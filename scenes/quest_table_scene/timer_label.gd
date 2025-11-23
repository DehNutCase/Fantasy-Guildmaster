extends Label

@export var time_remaining:float = 20.0

func _ready() -> void:
	update_label()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if GlobalData.paused or GlobalData.time_over:
		return
	time_remaining -= clamp(delta, 0, time_remaining)
	if !time_remaining:
		GlobalData.time_over = true
	update_label()

func update_label() -> void:
	text = "%ss" %str(time_remaining).pad_decimals(2)
