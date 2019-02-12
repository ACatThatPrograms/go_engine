extends "res://ui/components/game_menus/menu_base.gd"

var DEBUG_MODE = false

## Substate for active window

var sub_state = "who"

var windows_loaded = false

## Specific Readiness Flags

var ready_for_input_main = false
var ready_for_input_who = false
var ready_for_input_which = false

var who_anim_playing = false

var active_entity = null ## Active Entity using Menu ( Not character, this is a menu obj )

var item_count = 0 		# Current amount of items in inventory
var item_max = 14 		# Max amount of items allowed in inventory

# Item list is populated by the using item.fetch_item(itemID) based on load inventories
# ItemIDs are found in a list @ player.inventory
var item_list = []

# Currently selected item :: Resets on menu leave
var item_selection = 1

# Necessary references
onready var text_box = get_parent().get_node('text_box')
onready var ui = get_parent()

## Individual Inventories

# Array that loads inventories based on ("party")[0].party_members
var inventories = [] # array[0][0] is inventory 0, array [0][1] is inv 0's owner object e.g player_2
var selected_inventory = 0

var equipments = [] # Array of equipments, just like inventories

# Box Switch Timers
var timer_max = 30
var timer = 0

func _ready():
	pass

func _process(delta):
	debug_input()
	match state:
		"inactive":
			pass
		"active":
			state_active()
		"using_item":
			state_using_item()

func state_active():
	if ready_for_input_main:
		match sub_state:
			"who":
				if ready_for_input_who:
					update_list()
					check_who()
				else:
					ready_for_input_who = true
			"which":
				if ready_for_input_which:
					check_which()
				else:
					ready_for_input_which = true
					
	else:
		ready_for_input_main = true
	window_tracker()
	
	if item_list.empty():
		hide_selectors()
	_animate_selector(item_selection)

func refresh_inventory(force_select = 0): ## Called on first load
	inventories.clear()
	equipments.clear()
	
	for x in get_tree().get_nodes_in_group("party")[0].party_members.size():
		inventories.append([get_tree().get_nodes_in_group("party")[0].party_members[x].inventory, get_tree().get_nodes_in_group("party")[0].party_members[x]])
		equipments.append([get_tree().get_nodes_in_group("party")[0].party_members[x].equipment, get_tree().get_nodes_in_group("party")[0].party_members[x]])
	selected_inventory = force_select
	set_name(inventories[selected_inventory][1].character_name)
	if DEBUG_MODE:
		var name_list = ""
		for x in inventories:
			name_list += ((x[1].character_name) + " ")
		print("Following inventories refreshed: %s" % name_list)
	update_list()

###################################
## WHO CHECK FUNCTIONS AND LOGIC ##
###################################

## Main Check_Who Loop, bypass if partysize == 0

func check_who():
	hide_selectors()
	## Party Size Check
	if game_data.party_members.size() == 1:
		selected_inventory = 0
		switch_sub_state("which")
	else:
		if who_anim_playing: ## Only allow input outside of animation
			pass
		else:
			who_loop_input()

func who_loop_input():
	# Right Input
	if Input.is_action_just_pressed("ui_right"):
		if selected_inventory + 1 <= inventories.size() - 1:
			switch_box("right")
		else:
			switch_box("force_start")
	# Left Input
	if Input.is_action_just_pressed("ui_left"):
		if selected_inventory - 1 >= 0:
			switch_box("left")
		else:
			switch_box("force_end")
	# Cancel Input
	if Input.is_action_just_pressed("snes_b"):
		audio.get_node("sfx").play_sound(dict.sfx_id["[7]"])
		ready_for_input_who = false
		selected_inventory = 0
		update_list()
		ui.close_goods_menu()
	# Accept Input
	if Input.is_action_just_pressed("snes_a"):
		audio.get_node("sfx").play_sound(dict.sfx_id["[4]"])
		ready_for_input_who = false
		$menu_arrows.hide()
		switch_sub_state("which")

func switch_box(dir):
	$anim.connect("animation_finished", self, "_anim_switch_box", [dir], 4)
	$anim.play("box_switch")
	audio.get_node("sfx").play_sound(dict.sfx_id["[7]"])
	who_anim_playing = true
	## Set name pre-anim
	if dir == "right":
		set_name(inventories[selected_inventory + 1][1].character_name)
		$arrow_anim.play("arrow_right")
	elif dir == "left":
		set_name(inventories[selected_inventory - 1][1].character_name)
		$arrow_anim.play("arrow_left")
	elif dir == "force_start":
		set_name(inventories[0][1].character_name)
		$arrow_anim.play("arrow_right")
	elif dir == "force_end":
		set_name(inventories[inventories.size() - 1][1].character_name)
		$arrow_anim.play("arrow_left")
	

## Animation Functions && Call Backs

func _anim_switch_box(a, direction):
	if direction == "right":
		selected_inventory += 1
	elif direction == "left":
		selected_inventory -= 1
	elif direction == "force_start":
		selected_inventory = 0
	elif direction == "force_end":
		selected_inventory = inventories.size() - 1
	who_anim_playing = false
	if DEBUG_MODE:
		print("Loading inventory %s, owned by %s" % [selected_inventory, inventories[selected_inventory][1].character_name])

###################################
## WHICH CHECK FUNCTIONS AND LOGIC ##
###################################

func check_which():
	
	if !inventories[selected_inventory][1].is_connected("equip_change", self, "_equipment_changed"):
		inventories[selected_inventory][1].connect("equip_change", self, "_equipment_changed")
		
	_menuController()
	_selectionHighlight()

func _menuController():
	
	if item_selection > item_count:
		item_selection -= 1
	
	## WHICH_LOOP INPUTS
	
	### UI DOWN
	if Input.is_action_just_pressed("ui_down"):
		audio.get_node("sfx").play_sound(dict.sfx_id["[6]"])
		var to_select = item_selection + 2
		if to_select > item_count:
			pass
		else:
			item_selection = to_select
			if DEBUG_MODE:
				print("Goods_Menu :: Selected Item: ", item_selection)
	
	### UI UP
	if Input.is_action_just_pressed("ui_up"):
		audio.get_node("sfx").play_sound(dict.sfx_id["[6]"])
		var to_select = item_selection - 2
		if to_select > item_count || to_select <= 0:
			pass
		else:
			item_selection = to_select
			if DEBUG_MODE:
				print("Goods_Menu :: Selected Item: ", item_selection)
	
	### UI RIGHT
	if Input.is_action_just_pressed("ui_right"):
		audio.get_node("sfx").play_sound("res://sound/fx/curshoriz.wav")
		var to_select = item_selection + 1
		if to_select > item_count:
			pass
		else:
			item_selection = to_select
			if DEBUG_MODE:
				print("Goods_Menu :: Selected Item: ", item_selection)
	
	
	### UI LEFT
	if Input.is_action_just_pressed("ui_left"):
		audio.get_node("sfx").play_sound("res://sound/fx/curshoriz.wav")
		var to_select = item_selection - 1
		if to_select > item_count || to_select <= 0:
			pass
		else:
			item_selection = to_select
			if DEBUG_MODE:
				print("Goods_Menu :: Selected Item: ", item_selection)
	
	### UI CANCEL
	if Input.is_action_just_pressed("snes_b") && ready_for_input_which:
		audio.get_node("sfx").play_sound(dict.sfx_id["[5]"])
		if inventories.size() > 1:
			reset_selected_item()
			switch_sub_state("who")
			$which_box.hide()
		else:
			$which_box.hide()
			ui.close_goods_menu()
	
	### UI CONTINUE
	if Input.is_action_just_pressed("snes_a") && ready_for_input_which:
		if item_list.empty():
			pass
		else:
			audio.get_node("sfx").play_sound(dict.sfx_id["[4]"])
			var item = item_list[item_selection - 1]
			$who_box.hide()
			$which_box.hide()
			if DEBUG_MODE:
				print(inventories[selected_inventory][1].character_name," Selected: ", item.DATA["NAME"])
			select_item(item)

####################
## WINDOW TRACKER ##
####################

func window_tracker(): # Matches viewable windows to sub_state
	## View conditions
	if !windows_loaded:
		match sub_state:
			"who":
				### HIDE
				$which_box.hide()
				$whom_box.hide()
				## SHOW
				$who_box.show()
				$menu_arrows.show()
			"which":
				## HIDE
				$who_box.hide()
				$whom_box.hide()
				$menu_arrows.hide()
				## SHOW
				$which_box.show()
	else:
		pass
############################
## USING ITEM STATE LOGIC ##
############################

func state_using_item():
	if text_box.text_over:
		switch_state("active")
	else:
		pass

####################
## OPEN // CLOSE  ##
####################

func open(opening_entity):
	if DEBUG_MODE:
		print(opening_entity.name, " is entering: goods_menu")
	active_entity = opening_entity
	active_entity.switch_state("inactive")
	show()

####################
## STATE HANDLING ##
####################

func switch_state(newState):
	state = newState

func switch_sub_state(newState):
	sub_state = newState
	windows_loaded = false

################################
## ITEM LIST LOGIC && LOADING ##
################################

## Refreshes Inventory List :: Should be called after changes
func update_list():
	clear_item_list()
	if !equipments[selected_inventory][0].empty():
		equipments[selected_inventory][0].sort()
		for id in equipments[selected_inventory][0]:
			var itemToAdd = item.fetch_item(id)
			var item_label = get_node("items").get_node("item_" + str(item_count + 1))
			itemToAdd.DATA["EQUIPPED"] = true
			item_label.bbcode_text = "[img]res://ui/assets/equip_symbol.png[/img] " + itemToAdd.DATA["NAME"]
			item_list.append(itemToAdd)
			item_count += 1
			inventories[0][1].get_node("equipment").add_child(itemToAdd)
	inventories[selected_inventory][0].sort()
	for id in inventories[selected_inventory][0]:
		var itemToAdd = item.fetch_item(id)
		var item_label = get_node("items").get_node("item_" + str(item_count + 1))
		item_label.text = itemToAdd.DATA["NAME"]
		item_list.append(itemToAdd)
		item_count += 1
		inventories[0][1].get_node("inventory").add_child(itemToAdd)
	
	var selected_block = int(inventories[selected_inventory][1].status_block.name[6])
	if get_parent().get_node("status_blocks").active_block != selected_block:
		get_parent().get_node("status_blocks").active_block = selected_block

## Clears inventory and resets necessary values
func clear_item_list():
	#Clears internal item list and resets item count
	item_list.clear()
	item_count = 0
	# Resets GUI elements to null
	for item in $items.get_children():
		item.bbcode_text = ""
	for i in inventories[selected_inventory][1].get_node("inventory").get_children():
		i.queue_free()
	for i in inventories[selected_inventory][1].get_node("equipment").get_children():
		i.queue_free()
	

## Add item :: itemToAdd should be newly instanced item node
func add_item(itemToAdd):
	inventories[selected_inventory][1].get_node("inventory").add_child(itemToAdd)
	update_list()

## Remove item :: itemToRemove should be node object from inventory node
func remove_item(itemToRemove):
	var removed = false
	for id in inventories[selected_inventory][0]:
		if removed:
			pass
		else:
			if id == itemToRemove.DATA["ID"]:
				inventories[selected_inventory][0].erase(id)
				removed = true
				update_list()

######################
## ITEM INTERACTION ##
######################

# Select item from Goods Menu and open sub_menu
# Uses item from item_list node reference
func select_item(sel_item):
	$goods_sub_menu.open(self, sel_item, inventories[selected_inventory][1])

################
## UI SIGNALS ##
################

func _goods_menu_opened():
	refresh_inventory()
	switch_state("active")

func _goods_menu_closed():
	switch_state("inactive")
	if DEBUG_MODE:
		print(active_entity.name, " is closing goods menu.")
	reset_ready_inputs()
	active_entity.switch_state("active")
	active_entity = null
	reset_selected_item()
	refresh_inventory()
	hide()

func _equipment_changed():
	if DEBUG_MODE:
		print("Refreshing inventory on equipment change")
	refresh_inventory(selected_inventory)

##################################################
## SELECTION HIGHLIGHTING && INV ARROW ANIMATION##
##################################################

func _selectionHighlight():
	hide_selectors()
	match item_selection: #Shows appropriate selector
	
		1:
			$selected/selected_1.show()
		2:
			$selected/selected_2.show()
		3:
			$selected/selected_3.show()
		4:
			$selected/selected_4.show()
		5:
			$selected/selected_5.show()
		6:
			$selected/selected_6.show()
		7:
			$selected/selected_7.show()
		8:
			$selected/selected_8.show()
		9:
			$selected/selected_9.show()
		10:
			$selected/selected_10.show()
		11:
			$selected/selected_11.show()
		12:
			$selected/selected_12.show()
		13:
			$selected/selected_13.show()
		14:
			$selected/selected_14.show()

func _animate_selector(selected):
	if arrow_blink_rate == 0:
		## Flash selector arrows
		for node in get_tree().get_nodes_in_group("goods_selected"):
			if node.name == "selected_" + str(item_selection):
				if node.frame == 0:
					node.frame = 1
				else:
					node.frame = 0
		## Flash menu_arrows
		if !who_anim_playing:
			if $menu_arrows.frame == 0:
				$menu_arrows.frame = 1
			else:
				$menu_arrows.frame = 0
		arrow_blink_rate = arrow_blink_rate_init
	else:
		arrow_blink_rate -= 1

func hide_selectors():
	for selector in get_tree().get_nodes_in_group("goods_selected"):
		selector.hide()

func reset_selected_item():
	item_selection = 1

####################
## MISC FUNCTIONS ##
####################

#Updates Inventory-Name
func set_name(name): # Sets inventory name
	$name.text = name

func reset_ready_inputs():
	ready_for_input_main = false
	ready_for_input_who = false
	ready_for_input_which = false

####################
## DEBUGGING	  ##
####################

func debug_input():
	if Input.is_action_just_pressed("toggle_goods_debug"):
		DEBUG_MODE = !DEBUG_MODE
		print("Goods Menu Debug Enabled: %s" % DEBUG_MODE)