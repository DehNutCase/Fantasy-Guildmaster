class_name AdventurerCard
extends Control

enum States {BASE, DRAGGING, RELEASED, QUESTING}
var current_state:States = States.BASE
var targets = []
@onready var original_parent = get_parent()
@onready var label = %RichTextLabel
@onready var original_min_size = custom_minimum_size
@onready var icon = %Icon
@onready var target_icon = %TargetIcon

signal dragging_started

#region
@export var adventurer_id:String = ""
@export var adventurer_name:String = ""
@export var adventurer_icon:Texture2D
@export var stats = {
	"Atk": 0,
	"Def": 0,
	"Mag": 0,
	"Res": 0,
	"Spd": 0,
	"Luk": 0,
}
var stat_order = ["Atk", "Def", "Mag", "Res", "Spd", "Luk"]
#endregion

func _ready() -> void:
	load_adventurer()

func load_adventurer() -> void:
	if adventurer_id in GlobalConstants.adventurers:
		var adventurer_data = GlobalConstants.adventurers[adventurer_id]
		adventurer_icon = adventurer_data.icon
		stats = adventurer_data.stats.duplicate(true)
		adventurer_name = adventurer_data.name
		update_label()
	else:
		printerr("adventurer_id not found for load_adventurer in adventurer_card")
	pass

func update_label() -> void:
	label.clear()
	var text = "\n[center]" + adventurer_name + "[/center]\n\n"
	text += "[center][table=2]"
	for stat in stat_order:
		text += "[cell] " + stat + ": " + calculate_rating(stat) + " [/cell]"
	text += "[/table][/center]"
	label.append_text(text)
	icon.texture = adventurer_icon
	target_icon.texture = adventurer_icon

func calculate_rating(stat_name:String) -> String:
	var stat_value = stats[stat_name]
	#The tuple should be in the format of ["RatingLetter", Breakpoint]
	for tuple in GlobalConstants.rating_breakpoints:
		if stat_value > tuple[1]:
			return tuple[0]
	return "F"
	
func _gui_input(event):
	match current_state:
		States.BASE:
			if event.is_action_pressed("ui_click"):
				change_state(current_state, States.DRAGGING)

func _input(event):
	match current_state:
		States.DRAGGING:
			if event is InputEventMouseMotion or InputEventJoypadMotion:
				target_icon.global_position = get_global_mouse_position() - target_icon.size/2
			if event.is_action("ui_click"):
				change_state(current_state, States.RELEASED)
				get_viewport().set_input_as_handled()
			if event.is_action_pressed("cancel"):
				change_state(current_state, States.BASE)
				get_viewport().set_input_as_handled()
			if event.is_action("ui_mouse_wheel_up"):
				%QuestScrollContainer.scroll_vertical -= 40
				target_icon.global_position = get_global_mouse_position() - target_icon.size/2
			if event.is_action("ui_mouse_wheel_down"):
				%QuestScrollContainer.scroll_vertical += 40
				target_icon.global_position = get_global_mouse_position() - target_icon.size/2
			
	
func _on_area_area_entered(area: Area2D) -> void:
	if !(area in targets):
		targets.append(area)
		if current_state != States.DRAGGING:
			return
		for target in targets:
			target.get_parent().on_adventuerer_card_stop_hover()
		area.get_parent().on_adventurer_card_hover(self)

func _on_area_area_exited(area: Area2D) -> void:
	targets.erase(area)
	if current_state != States.DRAGGING:
		return
	area.get_parent().on_adventuerer_card_stop_hover()
	if targets:
		targets[-1].get_parent().on_adventurer_card_hover(self)

func change_state(from:States, to:States) -> void:
	exit_state(from)
	enter_state(to)
	
func enter_state(state:States) -> void:
	current_state = state
	match state:
		States.DRAGGING:
			GlobalData.slow_down_list.append(adventurer_name)
			if targets:
				targets[-1].get_parent().on_adventurer_card_hover(self)
			dragging_started.emit(self)
			self_modulate = Color.GOLD
			target_icon.global_position = get_global_mouse_position() - target_icon.size/2
			target_icon.show()

		States.BASE:
			label.show()
			scale = Vector2(1,1)
			custom_minimum_size = original_min_size
			reparent(original_parent)
		States.RELEASED:
			scale = Vector2(1,1)
			if targets:
				var quest_card:QuestCard = targets[-1].get_parent()
				quest_card.add_adventurer(self)
				change_state(current_state, States.QUESTING)
			else:
				change_state(current_state, States.BASE)
		States.QUESTING:
			custom_minimum_size = original_min_size * .2
			label.hide()
		

func exit_state(state:States) -> void:
	match state:
		States.DRAGGING:
			self_modulate = Color.WHITE
			target_icon.hide()
			target_icon.position = Vector2.ZERO
			GlobalData.slow_down_list.erase(adventurer_name)
			for target in targets:
				target.get_parent().on_adventuerer_card_stop_hover()

func process_rewards(stats_dict) -> void:
	for stat in stats_dict:
		var multiplier:float = 1.0
		if stat in GlobalConstants.adventurers[adventurer_id].growth_rate:
			multiplier = GlobalConstants.adventurers[adventurer_id].growth_rate[stat]
		stats[stat] += int(stats_dict[stat] * multiplier / 10.0)
	update_label()
