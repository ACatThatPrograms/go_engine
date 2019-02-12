extends "res://ui/components/game_menus/menu_base.gd"

onready var ui = get_parent()

var selected = 0

var last_entity

## All Menu Timer

var all_menu_frames = 0
var all_menu_frame_max = 48

func _ready():
	pass
	
func _process(delta):
	match state:
		"inactive":
			pass
		"active":
			all_menu_timeout()
			state_active()
	
func state_active():
	if ui.get_node("status_blocks").active_block != 0:
		ui.get_node("status_blocks").active_block = 0
	if ready_for_input:
		_menuController()
		_selectionHighlight()
	else:
		ready_for_input = true
	_animate_selector(selected)

func _menuController():
	
	if Input.is_action_just_pressed("ui_down"):
		audio.get_node("sfx").play_sound(dict.sfx_id["[6]"])
		if selected < 5:
			selected += 1
		else:
			selected = 0

	if Input.is_action_just_pressed("ui_up"):
		audio.get_node("sfx").play_sound(dict.sfx_id["[6]"])
		if selected > 0:
			selected -= 1
		else:
			selected = 5

	if Input.is_action_just_pressed("ui_right"):
		audio.get_node("sfx").play_sound(dict.sfx_id["[5]"])
		var toSelect = (selected + 3)
		if toSelect > 5:
			toSelect %= 6
			selected = toSelect
		else:
			selected = toSelect

	if Input.is_action_just_pressed("ui_left"):
		audio.get_node("sfx").play_sound(dict.sfx_id["[5]"])
		var toSelect = (selected - 3)
		if toSelect < 0:
			toSelect += toSelect + 6
			selected = toSelect
		else:
			selected = toSelect

	if Input.is_action_just_pressed("snes_a") && ready_for_input:
		if selected == 0:
			talk_to()
		if selected == 1:
			audio.get_node("sfx").play_sound(dict.sfx_id["[7]"])
			PSI()
		if selected == 2:
			check()
		if selected == 3:
			audio.get_node("sfx").play_sound(dict.sfx_id["[7]"])
			open_goods()
		if selected == 4:
			open_equip()
		if selected == 5:
			open_status()

	if Input.is_action_just_pressed("snes_b") && ready_for_input:
		audio.get_node("sfx").play_sound(dict.sfx_id["[5]"])
		ui.close_player_menu()

func open(opening_entity):
	last_entity = opening_entity
	opening_entity.switch_state("inactive")
	if engine.DEBUG:
		if opening_entity.get("character_name") != null:
			print("%s is entering player_menu" % opening_entity.character_name)
		else:
			print("%s is entering player_menu" % opening_entity.name)
	show()

## All menu timeout - shows rets of menus after set frame counts

func all_menu_timeout():
	if Input.is_action_just_pressed("ui_up") || Input.is_action_just_pressed("ui_down") || Input.is_action_just_pressed("ui_left") || Input.is_action_just_pressed("ui_right"):
		all_menu_frames = 0
	if all_menu_frames == all_menu_frame_max:
		ui.get_node("funds_box").show()
		ui.get_node("status_blocks").show()
	else:
		all_menu_frames +=1

## COMMAND FUNCTIONS ##

func talk_to():
	switch_state("inactive")
	ui.text_box().connect("text_done", self, "_talk_to_done", [], 4)
	get_tree().get_nodes_in_group("party")[0].leader.talk_to()

func _talk_to_done():
	ui.close_player_menu()

func PSI():
	ui.open_psi_menu(self)

func check():
	switch_state("inactive")
	ui.text_box().connect("text_done", self, "_talk_to_done", [], 4)
	get_tree().get_nodes_in_group("party")[0].leader.check()

func open_equip():
	audio.get_node("sfx").play_sound(dict.sfx_id["[7]"])
	ui.open_equip_menu(self)

func open_goods():
	get_parent().open_goods_menu(self)

func open_status():
	audio.get_node("sfx").play_sound(dict.sfx_id["[7]"])
	ui.open_status_menu(self)
	ui.get_node("funds_box").show()
	ui.get_node("status_blocks").show()

## UI SIGNALS

func _player_menu_opened():
	switch_state("active")

func _player_menu_closed():
	if engine.DEBUG:
		if last_entity.get("character_name") != null:
			print("%s is leaving player_menu" % last_entity.character_name)
		else:
			print("%s is leaving player_menu" % last_entity.name)
	get_tree().get_nodes_in_group("party")[0].leader.switch_state("active")
	ready_for_input = false
	selected = 0
	hide()
	switch_state("inactive")
	all_menu_frames = 0

## SELECTION ANIMATION & HANDLING BELOW ##

func switch_state(newState):
	state = newState

func _animate_selector(selected):
	if arrow_blink_rate == 0:
		for node in get_tree().get_nodes_in_group("selected"):
			if node.name == "selected_" + str(selected):
				if node.frame == 0:
					node.frame = 1
				else:
					node.frame = 0
		arrow_blink_rate = arrow_blink_rate_init
	else:
		arrow_blink_rate -= 1

func _selectionHighlight():
	_hideSelectors()
	match selected: #Shows appropriate selector
		0:
			$left/top_left/selected_0.show()
		1:
			$left/middle_left/selected_1.show()
		2:
			$left/bottom_left/selected_2.show()
		3:
			$right/top_right/selected_3.show()
		4:
			$right/middle_right/selected_4.show()
		5:
			$right/bottom_right/selected_5.show()

func _hideSelectors():
	for node in get_tree().get_nodes_in_group("selected"):
		node.hide()