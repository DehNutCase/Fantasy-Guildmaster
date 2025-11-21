class_name AdventurerCard
extends Control

enum States {BASE, DRAGGING, RELEASED, QUESTING}
var current_state:States = States.BASE
var targets = []
@onready var original_parent = get_parent()
@onready var label = %RichTextLabel
@onready var original_min_size = custom_minimum_size
@onready var icon = %Icon

signal dragging_started

#region
@export var adventurer_name:String = ""
@export var adventurer_icon:Texture2D = load("res://icon.svg")
@export var stats = {
	"Atk": 0,
	"Def": 0,
	"Mag": 0,
	"Res": 0,
	"Spd": 0,
	"Luk": 0,
}
#endregion

func _ready() -> void:
	update_label()

func update_label() -> void:
	label.clear()
	var text = "\n[center]" + adventurer_name + "[/center]\n\n"
	text += "[center][table=2]"
	for stat in stats:
		text += "[cell] " + stat + ": " + calculate_rating(stat) + " [/cell]"
	text += "[/table][/center]"
	label.append_text(text)
	icon.texture = adventurer_icon

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
				global_position = get_global_mouse_position() - size/4
			if event.is_action("ui_click"):
				change_state(current_state, States.RELEASED)
				get_viewport().set_input_as_handled()
			if event.is_action_pressed("cancel"):
				change_state(current_state, States.BASE)
				get_viewport().set_input_as_handled()
			
	
func _on_area_area_entered(area: Area2D) -> void:
	if !(area in targets):
		targets.append(area)
		if current_state != States.DRAGGING:
			return
		for target in targets:
			target.get_parent().modulate = Color.WHITE
		area.get_parent().modulate = Color.GOLD

func _on_area_area_exited(area: Area2D) -> void:
	targets.erase(area)
	if current_state != States.DRAGGING:
		return
	area.get_parent().modulate = Color.WHITE
	if targets:
		targets[-1].get_parent().modulate = Color.GOLD

func change_state(from:States, to:States) -> void:
	exit_state(from)
	enter_state(to)
	
func enter_state(state:States) -> void:
	current_state = state
	match state:
		States.DRAGGING:
			if targets:
				targets[-1].get_parent().modulate = Color.GOLD
			dragging_started.emit(self)
			scale = Vector2(.5,.5)
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
			for target in targets:
				target.get_parent().modulate = Color.WHITE
