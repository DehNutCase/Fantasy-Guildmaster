class_name HomeButton
extends TextureButton

@export var location:int
@export var action_name:String

func _ready() -> void:
	if location == 1:
		texture_pressed = load("res://assets/sprites/ui/edited/sg_menu03_resized.png")
		texture_hover = texture_pressed
	elif location == -1:
		texture_pressed = load("res://assets/sprites/ui/edited/sg_menu04_resized.png")
		texture_hover = texture_pressed
	else:
		texture_pressed = load("res://assets/sprites/ui/sg_menu05.png")
		texture_hover = texture_pressed
