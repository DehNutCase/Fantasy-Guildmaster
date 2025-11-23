extends Control

@onready var quest_grid = %QuestGrid
@onready var temp_container = %TempContainer

var quest_deck = ["dumpling_hunt", "unicorn_capture", "sword_smithing", "package_delivery", "bat_hunt", "hedgehog_hunt", "knight_spar", "skeleton_hunt", "herb_gather", "ore_gather"]
# Called when the node enters the scene tree for the first time.
var draws = 100

func _ready() -> void:
	_on_pause_button_pressed()
	for card:AdventurerCard in %AdventurersContainer.get_children():
		card.dragging_started.connect(reparent_adventurer_card)
	for i in range(draws):
		draw_quest()

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

func reparent_adventurer_card(node:AdventurerCard) -> void:
	node.reparent(temp_container)

func _on_pause_button_pressed() -> void:
	GlobalData.paused = !GlobalData.paused
	if GlobalData.paused:
		%PauseButton.text = "Resume (Spacebar)"
	else:
		%PauseButton.text = "Pause (Spacebar)"
