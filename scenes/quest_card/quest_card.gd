class_name QuestCard
extends Button

@onready var adventurer_container = %AdventurerContainer
@onready var progress_bar = %ProgressBar
@onready var label = %Label
@onready var quest_icon = %QuestIcon
@onready var background = %Background

var adventurer_stats = {
	"Atk": 0.0,
	"Def": 0.0,
	"Mag": 0.0,
	"Res": 0.0,
	"Spd": 0.0,
	"Luk": 0.0,
}

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
signal level_won
signal level_lost
var completed = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	progress_bar.max_value *= GlobalConstants.constants.PROGRESS_BAR_MULTIPLIER
	load_quest()
	reward_stats = quest_stats.duplicate(true)
	for stat in reward_stats:
		if reward_stats[stat] == 0.0:
			reward_stats[stat] = 1.0
		reward_stats[stat] *= .1
	for stat in quest_stats:
		if quest_stats[stat] == 0.0:
			quest_stats[stat] = 5000.0
		if stat in success_chance_stats:
			quest_stats[stat] *= 5.0
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

func _process(delta: float) -> void:
	if completed:
		material = load("res://resources/shaders/teleport_shader_material.tres")
		material.set_shader_parameter("progress", material.get_shader_parameter("progress") + delta)
		if material.get_shader_parameter("progress") >= .5:
			label.hide()
			progress_bar.hide()
		if material.get_shader_parameter("progress") > 1:
			GlobalData.slow_down_list.erase(quest_name)
			queue_free()
		return
	if GlobalData.paused or GlobalData.time_over:
		return
	for stat in adventurer_stats:
		if stat in success_speed_stats:
			progress_bar.value += (delta * GlobalData.slow_down_factor * 100.0 * GlobalConstants.constants.PROGRESS_BAR_MULTIPLIER *  adventurer_stats[stat]/quest_stats[stat])/float(quest_stacks)
			if progress_bar.value >= progress_bar.max_value:
				if !(quest_name in GlobalData.slow_down_list):
					GlobalData.slow_down_list.append(quest_name)

func add_adventurer(card:AdventurerCard) -> void:
	if is_main_quest and !adventurer_container.get_children() and !GlobalData.time_over:
		ProjectMusicController.play_stream(GlobalConstants.music.boss)
	
	var tween = create_tween()
	tween.tween_property(card, "global_position", adventurer_container.global_position + (adventurer_container.size * .5), .3)
	await tween.finished
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
	if completed:
		return
	if progress_bar.value >= progress_bar.max_value:
		var roll = randi_range(0, 100)
		if roll <= calculate_success_chance(adventurer_stats):
			for card:AdventurerCard in adventurer_container.get_children():
				card.change_state(card.current_state, card.States.BASE)
				var stacked_rewards = {}
				for stat in reward_stats:
					stacked_rewards[stat] = reward_stats[stat] * quest_stacks
				card.process_rewards(stacked_rewards)
			if is_main_quest:
				level_won.emit()
			completed = true
		else:
			progress_bar.value = 0
			for card:AdventurerCard in adventurer_container.get_children():
				card.change_state(card.current_state, card.States.BASE)
			adventurer_stats = {
				"Atk": 0.0,
				"Def": 0.0,
				"Mag": 0.0,
				"Res": 0.0,
				"Spd": 0.0,
				"Luk": 0.0,
			}
			update_label()
			GlobalData.slow_down_list.erase(quest_name)
			if is_main_quest:
				if !GlobalData.time_over:
					ProjectMusicController.play_stream(GlobalConstants.music.default)
				else:
					level_lost.emit()

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
