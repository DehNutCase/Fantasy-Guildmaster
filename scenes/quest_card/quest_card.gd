class_name QuestCard
extends Button

@onready var adventurer_container = %AdventurerContainer
@onready var progress_bar = %ProgressBar
@onready var label = %Label
@onready var quest_icon = %QuestIcon
var adventurer_stats = {}

@export var quest_stats = {
	"Atk": 0.0,
	"Def": 0.0,
	"Mag": 0.0,
	"Res": 0.0,
	"Spd": 0.0,
	"Luk": 0.0,
}
var reward_stats = {}
var difficulty = "E"
@export var quest_name = ""
var quest_target = ""
var quest_type = ""
var quest_stacks:int = 0
var success_chance_stats = ["Def", "Res", "Luk"]
var success_speed_stats = ["Atk", "Mag", "Spd"]
@export var is_main_quest = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_quest()
	reward_stats = quest_stats.duplicate(true)
	for stat in reward_stats:
		if reward_stats[stat] == 0.0:
			reward_stats[stat] = 2.0
	for stat in quest_stats:
		if quest_stats[stat] == 0.0:
			quest_stats[stat] = 5000.0
		quest_stats[stat] *= 3.0
	update_label()

func load_quest() -> void:
	if quest_name in GlobalConstants.quests:
		var quest_data = GlobalConstants.quests[quest_name]
		quest_icon.texture = quest_data.icon
		quest_stats = quest_data.quest_stats.duplicate(true)
		quest_target = quest_data.target
		quest_type = quest_data.type
		quest_stacks = 1
		difficulty = calculate_difficulty()
	else:
		printerr("quest_name not found for load_quest in quest_card")
	pass

func calculate_difficulty() -> String:
	var smallest_stat = 0.0
	for stat in success_chance_stats:
		if quest_stats[stat] == 0.0:
			continue
		if quest_stats[stat] < smallest_stat or smallest_stat == 0.0:
			smallest_stat = quest_stats[stat]
	for tuple in GlobalConstants.rating_breakpoints:
		if smallest_stat > tuple[1]:
			return tuple[0]
	return "F"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if GlobalData.paused or GlobalData.time_over:
		return
	for stat in adventurer_stats:
		if stat in success_speed_stats:
			progress_bar.value += (delta * 100.0 * adventurer_stats[stat]/quest_stats[stat])/float(quest_stacks)

func add_adventurer(card:AdventurerCard) -> void:
	card.reparent(adventurer_container)
	for stat in card.stats:
		if stat in adventurer_stats:
			adventurer_stats[stat] += card.stats[stat]
		else:
			adventurer_stats[stat] = card.stats[stat]
	update_label()

func calculate_success_chance(stats_dict) -> float:
	var success_chance:float = 0.0
	for stat in success_chance_stats:
		if !stat in stats_dict:
			continue
		success_chance += stats_dict[stat]*100.0/quest_stats[stat]
	return clamp(success_chance, 0.0, 100.0)

func update_label(success_chance:float = calculate_success_chance(adventurer_stats)) -> void:
	
	label.text = quest_type + ": %d %s\n\nDifficulty: " %[quest_stacks, quest_target] + difficulty + "\n\nSuccess Chance: %s%%" %str(success_chance).pad_decimals(2)
	if is_main_quest:
		icon = load("res://assets/sprites/ui/element37_01.png")
	else:
		icon = null

func _on_pressed() -> void:
	if progress_bar.value >= 100:
		var roll = randi_range(0, 100)
		if roll <= calculate_success_chance(adventurer_stats):
			for card:AdventurerCard in adventurer_container.get_children():
				card.change_state(card.current_state, card.States.BASE)
				for stat in reward_stats:
					reward_stats[stat] *= quest_stacks
				card.process_rewards(reward_stats)
			queue_free()
		else:
			progress_bar.value = 0
			adventurer_stats = {}
			for card:AdventurerCard in adventurer_container.get_children():
				card.change_state(card.current_state, card.States.BASE)

func on_adventurer_card_hover(card:AdventurerCard) -> void:
	modulate = Color.GOLD
	var stats_copy = adventurer_stats.duplicate(true)
	for stat in card.stats:
		if stat in stats_copy:
			stats_copy[stat] += card.stats[stat]
		else:
			stats_copy[stat] = card.stats[stat]
	update_label(calculate_success_chance(stats_copy))

func on_adventuerer_card_stop_hover() -> void:
	modulate = Color.WHITE
	update_label()
