extends Area2D

var last_entity

func _ready():
	pass

func _process(delta):
	for x in get_overlapping_areas():
		x = x.get_parent()
		if x.TYPE == "PLAYER" && x.skin == "res://player/assets/ness_pajamas.png":
			x.get_node("tween").connect("tween_completed", self, "_tween_over", [], 4)
			x.walk_in_dir(dir._right, 10)
			last_entity = x

func _tween_over(a,b):
	ui.text_box().ready_box(last_entity)
	last_entity.switch_state("inactive")
	ui.text_box().load_read("I should get dressed first. [wait] [end]", last_entity)
	