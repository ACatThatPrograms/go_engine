extends "res://map_objects/inspection_box/inspection_box.gd"

func _ready():
	ui.text_box().connect("choice_yes", self, "_choice_yes")
	ui.text_box().connect("choice_no", self, "_choice_no")
	pass

func _choice_yes():
	active_entity.get_node("tween").connect("tween_completed", self, "_tween_complete", [], 4)
	active_entity.modulate_0()
	ui.text_box().switch_state("waiting")

func _choice_no():
	ui.text_box().load_command("I'll just keep these on then. [wait] [end]")
	ui.text_box().read_command(active_entity)

func _tween_complete(a, b):
	if active_entity.get_node("Sprite").texture == load("res://player/assets/ness_pajamas.png"):
		active_entity.change_texture("res://player/assets/ness.png")
	else:
		active_entity.change_texture("res://player/assets/ness_pajamas.png")
	active_entity.get_node("tween").connect("tween_completed", self, "_2_tween_complete", [], 4)
	active_entity.modulate_1()

func _2_tween_complete(a, b):
	ui.text_box().load_command("[end]")
	ui.text_box().read_command(active_entity)