extends "res://ui/components/game_menus/menu_base.gd"

var selected = 0

# Menu Option Node Array
onready var menu_opts = [$container/use, $container/give, $container/drop, $container/help]

# text_box Node

onready var text_box = get_parent().get_parent().get_node("text_box")

# Selected Item Placeholder
var active_item = null

# node using menu
var active_user = null

# Active Character
var active_char = null


func _ready():
	pass

func _process(delta):
	match state:
		"inactive":
			state_inactive()
		"active":
			if ready_for_input: ## Pauses one frame to allow input reset
				state_active()
			else:
				ready_for_input = true

func state_inactive():
	pass

func state_active():
	show_hide_selector()
	animate_selectors()
	
	if Input.is_action_just_pressed("ui_down"):
		audio.get_node("sfx").play_sound(dict.sfx_id["[6]"])
		if selected < 3:
			selected += 1
		else:
			pass
	
	if Input.is_action_just_pressed("ui_up"):
		audio.get_node("sfx").play_sound(dict.sfx_id["[6]"])
		if selected >= 1:
			selected -= 1
		else:
			pass
	
	if Input.is_action_just_pressed("snes_a"):
		audio.get_node("sfx").play_sound(dict.sfx_id["[4]"])
		match selected:
			0:
				use_item(active_char, active_item)
			1:
				print("Give", active_item.DATA["NAME"])
			2:
				print("Drop", active_item.DATA["NAME"])
			3:
				help_item(active_item)
		
	if Input.is_action_just_pressed("snes_b"):
		audio.get_node("sfx").play_sound(dict.sfx_id["[5]"])
		close()

## Item Interaction Logic

func use_item(char_target, item_to_use):
	if game_data.party_members.size() == 1:
		item_to_use.use(item_to_use, char_target, char_target, self)
	else:
		get_parent().get_node("char_selector").open(self, active_char, item_to_use)

func help_item(item):
	switch_state("inactive")
	text_box.connect("text_done", text_box, "_text_done", [self], 4) # 4 = one shot
	text_box.load_command(item.DATA["DESC"])
	text_box.read_command(self)
	

## Menu Open / Close

func open(opening_entity, selectedItem, active_character):
	if engine.DEBUG:
		print(opening_entity.name, " is opening goods_sub_menu for item: ", selectedItem.DATA["NAME"])
	opening_entity.switch_state("inactive")
	active_item = selectedItem
	switch_state("active")
	active_user = opening_entity
	active_char = active_character
	get_parent().get_node("which_box").hide()
	show()
	selected = 0

func close():
	if engine.DEBUG:
		print(active_user.name, " is leaving sub menu.")
	switch_state("inactive")
	selected = 0
	active_item = null
	hide()
	get_parent().get_node("which_box").show()
	active_user.switch_state("active")
	active_user = null
	ready_for_input = false
	active_char = null

## State Switcher

func switch_state(newState):
	state = newState

## Signaled functions

func text_done(): #Signalled on textbox [end]
	print("GOT THE SIGNAL")

## Selector Logic ##

func show_hide_selector():
	var index = 0
	for opt in menu_opts:
		if selected == index:
			opt.get_node("sub_selected").show()
		else:
			opt.get_node("sub_selected").hide()
		index += 1

func animate_selectors():
	if arrow_blink_rate == 0:
		for node in get_tree().get_nodes_in_group("sub_selected"):
				if node.frame == 0:
					node.frame = 1
				else:
					node.frame = 0
		arrow_blink_rate = arrow_blink_rate_init
	else:
		arrow_blink_rate -= 1