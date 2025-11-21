extends Control

@onready var quest_grid = %TempContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_on_pause_button_pressed()
	for card:AdventurerCard in %AdventurersContainer.get_children():
		card.dragging_started.connect(reparent_adventurer_card)

func reparent_adventurer_card(node:AdventurerCard) -> void:
	node.reparent(quest_grid)

func _on_pause_button_pressed() -> void:
	GlobalData.paused = !GlobalData.paused
	if GlobalData.paused:
		%PauseButton.text = "Resume (Spacebar)"
	else:
		%PauseButton.text = "Pause (Spacebar)"
