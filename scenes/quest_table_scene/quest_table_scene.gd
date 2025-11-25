extends Control

@onready var quest_grid = %QuestGrid
@onready var timer_label = %TimerLabel
@onready var tutorial_container = %TutorialContainer
var quest_deck = ["dumpling_hunt", "unicorn_capture", "sword_smithing", "package_delivery", "bat_hunt", "hedgehog_hunt", "knight_spar", "skeleton_hunt", "herb_gather", "ore_gather"]
# Called when the node enters the scene tree for the first time.
var draws = 100

signal level_lost
signal level_won

func _ready() -> void:
	ProjectMusicController.play_stream(GlobalConstants.music.default)
	_on_pause_button_pressed()
	for i in range(draws):
		draw_quest()
	timer_label.level_lost.connect(process_lose_signal)
	for quest_card:QuestCard in quest_grid.get_children():
		if quest_card.is_main_quest:
			quest_card.level_won.connect(process_win_signal)
			quest_card.level_lost.connect(process_lose_signal)

func process_win_signal() -> void:
	GlobalData.paused = true
	%PauseButton.text = "Resume (Spacebar)"
	ProjectMusicController.play_stream(GlobalConstants.music.victory)
	level_won.emit()
	
func process_lose_signal() -> void:
	ProjectMusicController.play_stream(GlobalConstants.music.defeat)
	level_lost.emit()
#TODO, add initial quests to quest grid here
func draw_quest() -> void:
	var quest_name = quest_deck.pick_random()
	for quest_card:QuestCard in quest_grid.get_children():
		if quest_card.quest_name == quest_name:
			quest_card.quest_stacks += 1
			quest_card.update_label()
			return
	
	var quest:QuestCard = load("res://scenes/quest_card/quest_card.tscn").instantiate()
	quest.quest_name = quest_name
	quest_grid.add_child(quest)

func _on_pause_button_pressed() -> void:
	GlobalData.paused = !GlobalData.paused
	if GlobalData.paused:
		%PauseButton.text = "Resume (Spacebar)"
	else:
		%PauseButton.text = "Pause (Spacebar)"

func _on_tutorial_button_pressed() -> void:
	GlobalData.paused = true
	tutorial_container.show()


func _on_close_tutorial_button_pressed() -> void:
	tutorial_container.hide()
