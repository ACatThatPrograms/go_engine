extends "res://ui/components/game_menus/menu_base.gd"

var name_tags = []

var selected_char = 0
var arrows = []

var last_entity

var active_char
var active_item

func _ready():
	hide()
	state = "inactive"
	for x in get_node("grid").get_children():	#Populate name_tage array
		name_tags.append([x, null])
	for x in get_tree().get_nodes_in_group("char_arrow"):
		arrows.append(x)
	

func _process(delta):
	match state:
		"inactive":
			pass
		"active":
			update_available_chars()
			if ready_for_input:
				menu_controls()
			else:
				ready_for_input = true
			arrow_animator()

func menu_controls():
	## UI Left
	if Input.is_action_just_pressed("ui_left"):
		audio.get_node("sfx").play_sound(dict.sfx_id["[5]"])
		if selected_char - 1 < 0:
			selected_char = get_tree().get_nodes_in_group("party")[0].party_members.size() - 1
		else:
			selected_char -= 1
	## UI Right
	if Input.is_action_just_pressed("ui_right"):
		audio.get_node("sfx").play_sound(dict.sfx_id["[5]"])
		if selected_char + 1 > get_tree().get_nodes_in_group("party")[0].party_members.size() - 1:
			selected_char = 0
		else:
			selected_char += 1
	## UI Cancel
	if Input.is_action_just_pressed("snes_b"):
		audio.get_node("sfx").play_sound(dict.sfx_id["[5]"])
		close()
	## UI Continue
	if Input.is_action_just_pressed("snes_a"):
		audio.get_node("sfx").play_sound(dict.sfx_id["[4]"])
		active_item.use(active_item, active_char, name_tags[selected_char][1], self)
		print("Use %s on %s" % [active_item.DATA["NAME"], name_tags[selected_char][1].character_name])

	if Input.is_action_just_pressed("debug_num_9"):
		print(name_tags)
		print(active_char)
		print(active_item)

## Open & Close Functions

func open(opening_entity, using_entity, item_to_use):
	get_parent().get_node("whom_box").show()
	ready_for_input = false
	if engine.DEBUG:
		print("%s is opening the char_selector menu with active character: %s" % [opening_entity.name, using_entity.character_name])
	opening_entity.switch_state("inactive")
	last_entity = opening_entity
	active_char = using_entity
	active_item = item_to_use
	switch_state("active")
	show()

func close():
	hide()
	switch_state("inactive")
	get_parent().get_node("whom_box").hide()
	last_entity.switch_state("active")


## Arrow Animation & Hiding

func arrow_animator():
	for x in get_tree().get_nodes_in_group("char_arrow"):
		x.hide()
	match selected_char:
		0:
			arrows[0].show()
		1:
			arrows[1].show()
		2:
			arrows[2].show()
		3:
			arrows[3].show()
	
	if arrow_blink_rate < arrow_blink_rate_init:
		arrow_blink_rate += 1
	else:
		for x in arrows:
			if x.frame == 0:
				x.frame = 1
			else:
				x.frame = 0
		arrow_blink_rate = 0

## Update Char_Selector Box Size & Names

func update_available_chars():
	
	for x in name_tags: ## Hide Name Tags
		x[0].text = "hide"
	
	var i = 0 ## Iterator
	for x in get_tree().get_nodes_in_group("party")[0].party_members:
		
		name_tags[i][0].text = x.character_name
		name_tags[i][1] = x
		i += 1
	
	var total_shown = 0
	
	for x in name_tags:
		if x[0].text == "hide":
			x[0].hide()
		else:
			total_shown += 1
			x[0].show()
	
	match total_shown:
		1:
			pass
		2:
			rect_size.x 	=	106
			rect_position.x = 	85
		3:
			rect_size.x 	=	158
			rect_position.x = 	33
		4:
			rect_size.x 	=	216
			rect_position.x = 	-25

## STATE SWITCHING

func switch_state(newState):
	state = newState