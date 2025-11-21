class_name QuestCard
extends Button

@onready var adventurer_container = %AdventurerContainer
@onready var progress_bar = %ProgressBar
var adventurer_stats = {}

@export var quest_stats = {
	"Atk": 0,
	"Def": 0,
	"Mag": 0,
	"Res": 0,
	"Spd": 0,
	"Luk": 0,
}
var success_chance_stats = ["Def", "Res", "Luk"]
var success_speed_stats = ["Atk", "Mag", "Spd"]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for stat in quest_stats:
		quest_stats[stat] += 20
		quest_stats[stat] *= 9

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if GlobalData.paused:
		return
	for stat in adventurer_stats:
		if stat in success_speed_stats:
			progress_bar.value += delta * (adventurer_stats[stat]/quest_stats[stat]) * 100

func add_adventurer(card:AdventurerCard) -> void:
	card.reparent(adventurer_container)
	for stat in card.stats:
		if stat in adventurer_stats:
			adventurer_stats[stat] += card.stats[stat]
		else:
			adventurer_stats[stat] = card.stats[stat]


func _on_pressed() -> void:
	if progress_bar.value >= 100:
		#do quest completion stuff here
		for card:AdventurerCard in adventurer_container.get_children():
			card.change_state(card.current_state, card.States.BASE)
		queue_free()
