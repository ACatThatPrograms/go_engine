extends "res://areas/area_base.gd"

var head_bob_anim_iterator = 0

var t_flag_1 = false
var t_flag_2 = false
var t_flag_3 = false
var t_flag_4 = false

func _ready():
	$anim.connect("animation_finished", self, "_iterator_up")
	$anim.play("head_bob")
	pass

func _process(delta):
	remove_party_focus()
	pass

func _iterator_up(anim):
	if anim == "head_bob":
		head_bob_anim_iterator += 1
		$anim.play("head_bob")
		if head_bob_anim_iterator >= 3 && !t_flag_1:
			connect_text_box()
			ui.text_box().load_read("It's time to get up! [wait] [end] ", self)
			t_flag_1 = true
		if head_bob_anim_iterator >= 6 && !t_flag_2:
			connect_text_box()
			ui.text_box().load_read("Come on [char_0] ! [wait] [break] @ Don't keep [char_1] waiting. [wait] [end] ", self)
			t_flag_2 = true
		if head_bob_anim_iterator >= 9 && !t_flag_3:
			connect_text_box()
			ui.text_box().load_read("You've got 5 minutes before I send her up! [sfx] [14] [wait] [end]", self)
			t_flag_3 = true
		if head_bob_anim_iterator >= 11 && !t_flag_4:
			connect_text_box()
			connect_text_box("_scene")
			ui.text_box().load_read("(I guess I should get out of bed.) [wait] [break] [dd] . [dd] . [dd] . [wait] [end]", self)
			t_flag_4 = true

func _scene(a):
	get_tree().change_scene("res://areas/special/scene_1/scene_1.tscn")