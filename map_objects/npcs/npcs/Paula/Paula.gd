extends "res://map_objects/npcs/npc.gd"

func _ready():
	ui.text_box().connect_choice(self)
	pass

func _process(delta):
	check_command()

func check_command():
## With override script = true, place any textchanging
# flags here in order of gameplay from bottom to top
# Set all to set default etxt, then set special char texts below
	pass

func _choice_yes():
	ui.text_box().connect("text_done", self, "_join_party", [], 4)
	ui.text_box().ready_box(self)
	ui.text_box().load_read("Alright, let's get going! [wait] [end]", active_entity)

func _choice_no():
	ui.text_box().ready_box(self)
	ui.text_box().load_read("Well let me know when you're ready, okay? [wait] [end]", active_entity)

func _join_party():
	active_entity.switch_state("inactive")
	$tween.connect("tween_completed", self, "_join_party_2", [], 4) 
	switch_state("inactive")
	$collider.disabled = true
	walk_to(active_entity.position + Vector2(0,-1))

func _join_party_2(a,b):
	audio.get_node("music").stop()
	audio.get_node("sfx").play_sound(dict.sfx_id["[15]"])
	audio.get_node("sfx").connect("finished", self, "_sound", [], 4)
	ui.text_box().ready_box(active_entity)
	ui.text_box().load_read("( [char_1] joined the party! ) [pause] [wait] [end]", active_entity)
	modulate = Color(0,0,0,0)
	get_tree().get_nodes_in_group("party")[0].add_party_member(1)

func _sound():
	queue_free()
	ui.text_box().resume()
	audio.get_node("music").play()