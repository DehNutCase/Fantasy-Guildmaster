extends Label

@export var time_remaining:float = 20.0

signal level_lost

func _ready() -> void:
	update_label()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if GlobalData.paused or GlobalData.time_over:
		return
	time_remaining -= clamp(delta * GlobalData.slow_down_factor, 0, time_remaining)
	if !time_remaining:
		GlobalData.time_over = true
		for quest_card:QuestCard in %QuestGrid.get_children():
			if quest_card.is_main_quest and quest_card.progress_bar.value < 100.0:
				level_lost.emit()
	update_label()

func update_label() -> void:
	text = "%ss" %str(time_remaining).pad_decimals(2)
