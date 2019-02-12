extends "res://ui/components/game_menus/menu_base.gd"

var sub_state

## Signals

signal array_sorted

## Entity tracking

var active_char ## Active character entity
var last_entity ## Entity to last call menu, not character. e.g player_menu

## PSI Lists

var pre_sort_psi_array = [] # Access with type_select
var psi_array = [] # Sorted into sub_types, final sorted array

var offensive_psi = []
var recovery_psi = []
var assist_psi = []
var other_psi = []

var sub_types = [] ## Tracks PSI groups/slots
var levels = [] # Tracks selected PSI levels
var slot_index_level_array = []

## List Selection

var slot_index = 1
var level_index = 1
var level_selection = ""

## Type Index

var type_select

## Var Selector

var list_selector

## Char select

var sel_char = 1
var tar_char = 1
var selected_psi

func _ready():
	state = "inactive"
	list_selector = get_tree().get_nodes_in_group("list_sel")[0]
	connect("array_sorted", self , "_array_sorted")

func _process(delta):
	match state:
		"active":
			if ready_for_input:
				match sub_state:
					"who":
						if get_tree().get_nodes_in_group("party")[0].party_members.size() == 1:
							select_char(get_tree().get_nodes_in_group("party")[0].party_members[0])
						else:
							who_anims()
							who_input()
					"type":
						type_anims()
						type_input()
					"list":
						list_input()
						list_anims()
					"target":
						target_input()
						target_anims()
			else:
				ready_for_input = true
		"inactive":
			pass

################
## TYPE INPUT ##
################

func type_input():
	if Input.is_action_just_pressed("ui_up"):
		if type_select - 1 >= 0:
			audio.get_node("sfx").play_sound(dict.sfx_id["[6]"])
			type_select -= 1
			refresh_list()
	if Input.is_action_just_pressed("ui_down"):
		audio.get_node("sfx").play_sound(dict.sfx_id["[6]"])
		if type_select + 1 <= 3:
			type_select +=1
			refresh_list()
	
	if Input.is_action_just_pressed("snes_r") && $psi_list/l_r.is_visible():
		$psi_list/scroll_box.scroll_vertical += 17
	if Input.is_action_just_pressed("snes_l") && $psi_list/l_r.is_visible():
		$psi_list/scroll_box.scroll_vertical -= 17

	if Input.is_action_just_pressed("snes_a"):
		if psi_array[type_select].size() > 0:
			$psi_type/anim_type.stop()
			reset_list_selector()
			list_selector.show()
			switch_sub_state("list")
			shift_level("check")
			audio.get_node("sfx").play_sound(dict.sfx_id["[4]"])
		else:
			audio.get_node("sfx").play_sound(dict.sfx_id["[5]"])

	if Input.is_action_just_pressed("snes_b"):
		audio.get_node("sfx").play_sound(dict.sfx_id["[7]"])
		close()

################
## LIST INPUT ##
################

func list_input():
	if Input.is_action_just_pressed("ui_down"):
		if slot_index + 1 <= sub_types.size():
			audio.get_node("sfx").play_sound(dict.sfx_id["[6]"])
			slot_index += 1
			shift_slot()
	if Input.is_action_just_pressed("ui_up"):
		if slot_index - 1 >= 1:
			audio.get_node("sfx").play_sound(dict.sfx_id["[6]"])
			slot_index -= 1
			shift_slot()
	
	if Input.is_action_just_pressed("ui_right"):
		shift_level("right")
	if Input.is_action_just_pressed("ui_left"):
		shift_level("left")
	
	if Input.is_action_just_pressed("snes_a"):
		audio.get_node("sfx").play_sound(dict.sfx_id["[4]"])
		ui.status_blocks.active_block = get_tree().get_nodes_in_group("party")[0].party_members.find(active_char) + 1
		tar_char = ui.status_blocks.active_block
		select_psi()
	if Input.is_action_just_pressed("snes_b"):
		audio.get_node("sfx").play_sound(dict.sfx_id["[5]"])
		reset_list_selector()
		hide_list_selector()
		switch_sub_state("type")

func shift_slot():
	var shift_slot = "slot_" + str(slot_index)
	list_selector.get_parent().remove_child(list_selector)
	$psi_list/scroll_box/container.get_node(shift_slot).add_child(list_selector)
	
	if slot_index >= 3:
		if Input.is_action_just_pressed("ui_down"):
			$psi_list/scroll_box.scroll_vertical += 17
	if slot_index >= 1:
		if Input.is_action_just_pressed("ui_up"):
			$psi_list/scroll_box.scroll_vertical -= 17
	
	shift_level("check")

func shift_level(dir):
	slot_index_level_array = []
	for x in levels:
		if x[0] == slot_index:
			slot_index_level_array.append(x[1])
	match dir:
		"right":
			if level_index + 1 <= slot_index_level_array.size():
				level_index += 1
				level_selection = slot_index_level_array[level_index - 1]
				audio.get_node("sfx").play_sound(dict.sfx_id["[5]"])
		"left":
			if level_index - 1 >= 1:
				level_index -= 1
				level_selection = slot_index_level_array[level_index - 1]
				audio.get_node("sfx").play_sound(dict.sfx_id["[5]"])
		"check":
			if slot_index_level_array.has(level_selection):
				level_index = slot_index_level_array.find(level_selection) + 1
			else:
				level_index = 1
				level_selection = slot_index_level_array[0]

func select_psi():
	if get_tree().get_nodes_in_group("party")[0].party_members.size() == 1:
		use_psi(selected_psi, active_char, active_char)
	else:
		switch_sub_state("target")
		ui.status_blocks.active_block = 1

################
## WHO INPUT ##
################

func who_input():
	if Input.is_action_just_pressed("ui_right"):
		if sel_char + 1 <= get_tree().get_nodes_in_group("party")[0].party_members.size():
			sel_char += 1
			ui.status_blocks.active_block = sel_char
			audio.get_node("sfx").play_sound(dict.sfx_id["[5]"])
			$who_box/anim_who.play("arrow_right")
	if Input.is_action_just_pressed("ui_left"):
		if sel_char - 1 >= 1:
			sel_char -= 1
			ui.status_blocks.active_block = sel_char
			audio.get_node("sfx").play_sound(dict.sfx_id["[5]"])
			$who_box/anim_who.play("arrow_left")
			
	if Input.is_action_just_pressed("snes_a"):
		print("Sel char = %s" % sel_char)
		select_char(get_tree().get_nodes_in_group("party")[0].party_members[sel_char - 1])
		audio.get_node("sfx").play_sound(dict.sfx_id["[7]"])
	if Input.is_action_just_pressed("snes_b"):
		audio.get_node("sfx").play_sound(dict.sfx_id["[7]"])
		close()

func select_char(character):
	open(last_entity, character)
	$who_box.hide()

##################
## TARGET INPUT ##
##################

func target_input():
	if Input.is_action_just_pressed("ui_right"):
		if tar_char + 1 <= get_tree().get_nodes_in_group("party")[0].party_members.size():
			tar_char += 1
			ui.status_blocks.active_block = tar_char
			audio.get_node("sfx").play_sound(dict.sfx_id["[5]"])
			$whom_box/anim_whom.play("arrow_right")
	if Input.is_action_just_pressed("ui_left"):
		if tar_char - 1 >= 1:
			tar_char -= 1
			ui.status_blocks.active_block = tar_char
			audio.get_node("sfx").play_sound(dict.sfx_id["[5]"])
			$whom_box/anim_whom.play("arrow_left")
			
	if Input.is_action_just_pressed("snes_a"):
		use_psi(selected_psi, active_char, get_tree().get_nodes_in_group("party")[0].party_members[tar_char-1])
		audio.get_node("sfx").play_sound(dict.sfx_id["[7]"])
	
	if Input.is_action_just_pressed("snes_b"):
		audio.get_node("sfx").play_sound(dict.sfx_id["[7]"])
		switch_sub_state("list")

################
##  USE PSI   ##
################

func use_psi(psi, caster, target):
	if game_data.in_battle:
		pass
		## Battle Target Selection
	else:
		psi.use(active_char, target, self)

################
## ANIMATION  ##
################

## TYPE ANIM

func type_anims():
	
	##Hide Unrealted
	if $cost_box.is_visible():
		$cost_box.hide()
	
	if !$psi_type/anim_type.is_playing():
		$psi_type/anim_type.play("arrow_blink")

	match type_select:
		0:
			$psi_type/select.position.y = 15
		1:
			$psi_type/select.position.y = 31
		2:
			$psi_type/select.position.y = 47
		3:
			$psi_type/select.position.y = 63
	
	if !$psi_list/l_r/anim_lr.is_playing():
		$psi_list/l_r/anim_lr.play("arrow_flash")

## LIST ANIM

func list_anims():
	
	update_selected_psi()
	
	## Hide Unrelated
	if $whom_box.is_visible():
		$whom_box.hide()
	
	if ui.status_blocks.active_block != get_tree().get_nodes_in_group("party")[0].party_members.find(active_char) + 1:
		ui.status_blocks.active_block = get_tree().get_nodes_in_group("party")[0].party_members.find(active_char) + 1
	
	if !$cost_box.is_visible():
		$cost_box.show()
	
	match level_selection:
		"alpha":
			list_selector.position.x = 73
		"beta":
			list_selector.position.x = 88
		"gamma":
			list_selector.position.x = 103
		"omega":
			list_selector.position.x = 120
	
	if arrow_blink_rate > 0:
		arrow_blink_rate -= 1
	else:
		if list_selector.frame == 0:
			list_selector.frame = 1
		else:
			list_selector.frame = 0
		arrow_blink_rate = arrow_blink_rate_init
		
	## Update Cost
	match selected_psi.target:
		"ally_single":
			$cost_box/targeted.text = "To one of us"
		"ally_all":
			$cost_box/targeted.text = "To all of us"
		"enemy_single":
			$cost_box/targeted.text = "To single enemy"
		"enemy_row":
			$cost_box/targeted.text = "To enemy row"
		"enemy_all":
			$cost_box/targeted.text = "To all enemies"
	$cost_box/cost.text = str(selected_psi.cost)
	$cost_box/info_box/info.bbcode_text = selected_psi.description
	

func update_selected_psi():
	var sub_type_to_check = $psi_list/scroll_box/container.get_node("slot_" + str(slot_index)).text
	for x in psi_array[type_select]:
		for y in x:
			if y.sub_type == sub_type_to_check:
				if y.level == level_selection:
					selected_psi = y

## WHO Anim

func who_anims():
	
	##Hide Unrealted
	if $cost_box.is_visible():
		$cost_box.hide()
	
	if !$who_box.is_visible():
		$who_box.show()
	if !$who_box/anim_who.is_playing():
		$who_box/anim_who.play("arrow_flash")

## WHOM anim

func target_anims():
	if !$whom_box.is_visible():
		$whom_box.show()
	if !$whom_box/anim_whom.is_playing():
		$whom_box/anim_whom.play("arrow_flash")

################
## OPEN/CLOSE ##
################

func open(opening_entity, character = null):
	if character == null:
		opening_entity.switch_state("inactive")
		last_entity = opening_entity
		switch_state("active")
		sel_char = 1
		switch_sub_state("who")
		show()
		ready_for_input = false
		hide_list_selector()
		ui.status_blocks.show()
		ui.status_blocks.active_block = 1
		$psi_list.hide()
		$psi_type.hide()
	else:
		opening_entity.switch_state("inactive")
		last_entity = opening_entity
		active_char = character
		switch_state("active")
		switch_sub_state("type")
		show()
		ready_for_input = false
		hide_list_selector()
		## Below after char selection
		reset_type()
		update_psi_lists()
		$psi_list.show()
		$psi_type.show()

func close():
	hide()
	$psi_list.hide()
	$psi_type.hide()
	switch_state("inactive")
	last_entity.switch_state("active")

######################
## STATE SWITCHING  ##
######################

func switch_state(newState):
	state = newState

func switch_sub_state(newState):
	sub_state = newState

func reset_type():
	type_select = 0

func hide_list_selector():
	list_selector.hide()

func reset_list_selector():
	var selector = list_selector
	var cur_parent = selector.get_parent()
	
	cur_parent.remove_child(selector)
	$psi_list/scroll_box/container/slot_1.add_child(selector)
	
	$psi_list/scroll_box.scroll_vertical = 0
	slot_index = 1
	level_selection = "alpha"


#################
## UPDATE LIST ##
#################

func update_psi_lists():
	pre_sort_psi_array.clear()
	psi_array.clear()
	
	offensive_psi.clear()
	recovery_psi.clear()
	assist_psi.clear()
	other_psi.clear()
	
	for x in active_char.get_node("psi").get_children():
		match x.type:
			"offensive":
				offensive_psi.append(x)
			"recovery":
				recovery_psi.append(x)
			"assist":
				assist_psi.append(x)
			"other":
				other_psi.append(x)
	
	pre_sort_psi_array = [offensive_psi, recovery_psi, assist_psi, other_psi]
	
	for x in pre_sort_psi_array:
		sort_array(x)

func sort_array(array):
	var sub_types = []
	var sub_type_counter = 0
	## Find sub types available AKA Slots/PSI Groups
	for x in array:
		if sub_types.has(x.sub_type):
			pass
		else:
			sub_types.append(x.sub_type)
	## Creat new array and append empty arrays for corresponding amount of Slots
	var new_array = []
	for x in sub_types.size():
		new_array.append([])
	## Append PSI to sub-arrays
	var sub_type_iterator = 0
	for x in array:
		if x.sub_type == sub_types[sub_type_iterator]:
			new_array[sub_type_iterator].append(x)
		else:
			new_array[sub_type_iterator+1].append(x)
			sub_type_iterator += 1
	psi_array.append(new_array)
	
	if psi_array.size() == 4:
		emit_signal("array_sorted")

func _array_sorted():
	refresh_list()

func refresh_list():
	list_clear()
	$psi_list/l_r.hide()
	sub_types = []
	levels = []
	var slot_count = 1
	for x in psi_array[type_select]:
		var node_string = "slot_" + str(slot_count)
		$psi_list/scroll_box/container.get_node(node_string).text = x[0].sub_type
		for y in x:
			var level_to_show = y.level
			$psi_list/scroll_box/container.get_node(node_string).get_node(level_to_show).show()
			levels.append([slot_count, level_to_show])
		sub_types.append(x[0].sub_type)
		slot_count += 1

func list_clear():
	for x in $psi_list/scroll_box/container.get_children():
		for y in x.get_children():
			y.hide()
		x.text = ""