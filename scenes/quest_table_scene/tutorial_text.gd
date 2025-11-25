extends RichTextLabel


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_text()

func update_text() -> void:
	clear()
	var text_to_add = "Click and drag adventurers to send them on quests. Complete the main quest (denoted by the [img=%d]res://assets/sprites/ui/element37_01.png[/img]watermark) to win.\n\nQuesting speed is affected by Atk, Mag, and Spd stats. Quest success chance is affected by Def, Res, and Luk." %theme.default_font_size
	append_text(text_to_add)
