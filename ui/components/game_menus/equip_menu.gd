extends "res://ui/components/game_menus/menu_base.gd"

var active_char
var last_entity
var sub_state

var status_blocks

var window_updated = false
var equipment_updated = false

var equip_selector
var equip_selector_index = 1

## BB CODE IMG STRINGS & Default Texts
var equip_emblem = "[img]res://ui/assets/equip_symbol.png[/img]"
var unequipped_text = "( unequipped )"

func _ready():
	equip_selector = get_tree().get_nodes_in_group("equip_selector")[0]
	status_blocks = ui.status_blocks()

func _process(delta):
	match state:
		"active":
			match sub_state:
				"who":
					if ready_for_input:
						who_loop()
					else:
						ready_for_input = true
				"where":
					if ready_for_input:
						where_loop()
					else:
						ready_for_input = true
				"which":
					if ready_for_input:
						which_loop()
					else:
						ready_for_input = true
			window_tracker(sub_state)
			equipment_tracker()
		"inactive":
			pass

###############
## WHO STATE ##
###############

func who_loop():
	who_input()
	who_anims()

func who_input():
	if Input.is_action_just_pressed("ui_left"):
		if status_blocks.active_block - 1 >= 1:
			status_blocks.active_block -= 1
			equipment_updated = false
			audio.get_node("sfx").play_sound(dict.sfx_id["[5]"])
	if Input.is_action_just_pressed("ui_right"):
		if status_blocks.active_block + 1 <= get_tree().get_nodes_in_group("party")[0].party_members.size():
			status_blocks.active_block += 1
			equipment_updated = false
			audio.get_node("sfx").play_sound(dict.sfx_id["[5]"])
	
	if Input.is_action_just_pressed("snes_b"):
		audio.get_node("sfx").play_sound(dict.sfx_id["[7]"])
		close()
	if Input.is_action_just_pressed("snes_a"):
		who_continue()

func who_continue():
	active_char = get_tree().get_nodes_in_group("party")[0].party_members[status_blocks.active_block-1]
	equip_selector_index = 1
	audio.get_node("sfx").play_sound(dict.sfx_id["[4]"])
	switch_sub_state("where")

## ANIMATION

func who_anims():
	if !$equip_box/name/who_arrows.is_visible():
		$equip_box/name/who_arrows.show()
		$equip_box/name/arrow_anim.play("arrow_flash")
	
	$equip_box/name/name.text = get_tree().get_nodes_in_group("party")[0].party_members[status_blocks.active_block -1].character_name

#################
## WHERE STATE ##
#################

func where_loop():
	where_anims()
	where_input()

func where_input():
	if Input.is_action_just_pressed("ui_down"):
		if equip_selector_index + 1 <= 4:
			equip_selector_index += 1
			audio.get_node("sfx").play_sound(dict.sfx_id["[6]"])
	if Input.is_action_just_pressed("ui_up"):
		if equip_selector_index - 1 >= 1:
			equip_selector_index -= 1
			audio.get_node("sfx").play_sound(dict.sfx_id["[6]"])
	if Input.is_action_just_pressed("snes_a"):
		where_continue_press()
	if Input.is_action_just_pressed("snes_b"):
		where_back_press()

func where_back_press():
	if get_tree().get_nodes_in_group("party")[0].party_members.size() > 1:
		switch_sub_state("who")
		audio.get_node("sfx").play_sound(dict.sfx_id["[5]"])
	else:
		audio.get_node("sfx").play_sound(dict.sfx_id["[7]"])
		close()

func where_continue_press():
	pass

## ANIMATION

func where_anims():
	equip_selector_anim()
	equip_selector_tracking()

func equip_selector_anim():
	if arrow_blink_rate_init > 0:
		arrow_blink_rate_init -= 1
	else:
		if equip_selector.frame == 1:
			equip_selector.frame = 0
		else:
			equip_selector.frame = 1
		arrow_blink_rate_init = arrow_blink_rate

func equip_selector_tracking():
	match equip_selector_index:
		1:
			equip_selector.position.y = 15
		2:
			equip_selector.position.y = 32
		3:
			equip_selector.position.y = 48
		4:
			equip_selector.position.y = 64

#################
## WHICH STATE ##
#################

func which_loop():
	pass

## ANIMATION

func which_anims():
	pass

#################
## OPEN/CLOSE  ##
#################

func open(calling_entity):
	if engine.DEBUG:
		print(calling_entity.name, " opening equipment.")
	active_char = get_tree().get_nodes_in_group("party")[0].party_members[0]
	status_blocks.active_block = 1
	status_blocks.show()
	last_entity = calling_entity
	last_entity.switch_state("inactive")
	switch_state("active")
	ready_for_input = false
	equipment_updated = false
	equip_selector_index = 1
	show()
	## Choose state based on party size
	if get_tree().get_nodes_in_group("party")[0].party_members.size() > 1:
		switch_sub_state("who")
	else:
		switch_sub_state("where")

func close():
	switch_state("inactive")
	hide()
	last_entity.switch_state("active")

func window_tracker(sub_state):
	if !window_updated:
		match sub_state:
			"who":
				## Hide these
				$where_box.hide()
				$which_box.hide()
				equip_selector.hide()
				## Show these
				$who_box.show()
				$equip_box.show()
				window_updated = true
			"where":
				## Hide these
				$who_box.hide()
				$which_box.hide()
				$equip_box/name/who_arrows.hide()
				## Show these
				$where_box.show()
				$equip_box.show()
				equip_selector.show()
				$equip_box/name/name.text = get_tree().get_nodes_in_group("party")[0].party_members[status_blocks.active_block -1].character_name
				window_updated = true
			"which":
				## Hide these
				$who_box.hide()
				$where_box.hide()
				$equip_box/name/arrow_anim.hide()
				equip_selector.hide()
				## Show these
				$which_box.show()
				$equip_box.show()
				window_updated = true
	else:
		pass

func equipment_tracker():
	if !equipment_updated:
		var character = get_tree().get_nodes_in_group("party")[0].party_members[status_blocks.active_block-1]
		character.refresh_equipment()
		## POPULATE WEAPON
		if character.EQUIP_WEAPON == null:
			$equip_box/equipment/weapon/name.bbcode_text = unequipped_text
		else:
			$equip_box/equipment/weapon/name.bbcode_text = equip_emblem + " " + character.EQUIP_WEAPON.DATA["NAME"]
		## POPULATE BODY
		if character.EQUIP_BODY == null:
			$equip_box/equipment/body/name.bbcode_text = unequipped_text
		else:
			$equip_box/equipment/body/name.bbcode_text = equip_emblem + " " + character.EQUIP_BODY.DATA["NAME"]
		## POPULATE ARMS
		if character.EQUIP_ARMS == null:
			$equip_box/equipment/arms/name.bbcode_text = unequipped_text
		else:
			$equip_box/equipment/arms/name.bbcode_text = equip_emblem + " " + character.EQUIP_ARMS.DATA["NAME"]
		## POPULATE OTHER
		if character.EQUIP_OTHER == null:
			$equip_box/equipment/other/name.bbcode_text = unequipped_text
		else:
			$equip_box/equipment/other/name.bbcode_text = equip_emblem + " " + character.EQUIP_OTHER.DATA["NAME"]
		equipment_updated = true
	else:
		pass

######################
## STATE MANAGEMENT ##
######################

func switch_state(newState):
	state = newState

func switch_sub_state(newState):
	window_updated = false
	sub_state = newState