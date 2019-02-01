extends Container

var DEBUG_STATUS_BOX = false

var ready_for_input = false

var last_entity = null

var block_list = []
var active_block = 0

var state = "inactive"

signal blocks_loaded

var block_counter = 1
var total_blocks = 4

func _init():
	pass

func _ready():
	for x in get_tree().get_nodes_in_group("status_blocks"):
		block_list.append(x)

func _process(delta):
	debug_input()
	h_align() ## This needs refactored... Hbox resets vertical position...?
	match state:
		"inactive":
			check_death()
			check_active_block_loop()
		"active":
			check_death()
			check_active_block_loop()
			if ready_for_input:
				inputs()
			else:
				ready_for_input = true

func h_align():
	var child_node_array = []
	for x in get_children():
		if x.is_visible():
			child_node_array.append(x)
	
	match child_node_array.size():
		1:
			child_node_array[0].rect_position.x = 100
		2:
			child_node_array[0].rect_position.x = 72
			child_node_array[1].rect_position.x = 128
		3:
			child_node_array[0].rect_position.x = 44
			child_node_array[1].rect_position.x = 100
			child_node_array[2].rect_position.x = 156
		4:
			child_node_array[0].rect_position.x = 16
			child_node_array[1].rect_position.x = 72
			child_node_array[2].rect_position.x = 128
			child_node_array[3].rect_position.x = 184

func reset_block_positions():
	for x in block_list:
		x.rect_position.y = 0

func check_death():
	var collapse_all = false
	for x in block_list:
		if x.collapsed:
			collapse_all = true
	if collapse_all:
		for x in block_list:
			x.texture = preload("res://ui/assets/status_block_red.png")
	else:
		for x in block_list:
			x.texture = preload("res://ui/assets/status_block.png")	

func check_active_block_loop():
	
	reset_block_positions()
	
	match active_block:
		0:
			pass
		1:	
			block_list[0].rect_position.y = -8
		2:
			block_list[1].rect_position.y = -8
		3:
			block_list[2].rect_position.y = -8
		4:
			block_list[3].rect_position.y = -8

func set_active_block(dir, block_num = null):
	if dir == null:
		active_block = block_num - 1
	else:
		if dir == "up":
			if active_block + 1 > 4:
				active_block = 4
			else:
				active_block += 1
		if dir == "down":
			if active_block - 1 < 0:
				active_block = 0
			else:
				active_block -= 1

## Open and close functions

func open(opening_entity):
	if engine.DEBUG:
		print(opening_entity.character_name + " opened status_blocks")
	opening_entity.switch_state("inactive")
	last_entity = opening_entity
	active_block = 0
	show()

#Inputs
func inputs():
	if Input.is_action_just_pressed("snes_b"):
		audio.get_node("sfx").play_sound(dict.sfx_id["[5]"])
		get_parent().close_status_blocks()
	if Input.is_action_just_pressed("snes_a"):
		get_tree().get_nodes_in_group("ui")[0].open_player_menu(self)
		audio.get_node("sfx").play_sound(dict.sfx_id["[4]"])
		switch_state("inactive")

#Signals
func _status_blocks_opened():
	switch_state("active")

func _status_blocks_closed():
	if engine.DEBUG:
		print(get_tree().get_nodes_in_group("party")[0].leader.character_name + " closed status_blocks")
	get_tree().get_nodes_in_group("party")[0].leader.switch_state("active")
	hide()
	ready_for_input = false
	switch_state("inactive")

func _player_menu_closed():
	hide()
	switch_state("inactive")
	ready_for_input = false

func _goods_menu_opened():
	show()

#State switcher
func switch_state(newState):
	state = newState

func debug_input():
	
	if Input.is_action_just_pressed("debug_num_4"):
		set_active_block("down")
		print(active_block)
	if Input.is_action_just_pressed("debug_num_6"):
		set_active_block("up")
		print(active_block)
	if Input.is_action_just_pressed("debug_num_1"):
		set_active_block(null, 0)
		print(active_block)