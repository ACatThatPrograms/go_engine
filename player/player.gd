extends "res://engine/entity.gd"

var DEBUG_MODE = false ## Toggle via debug controls, not here

var is_following = false ## Flags if follower if party leader

## Signals
signal party_position_update ## Signals party position has changed
signal equip_change # Signals equipment change for goods and inventory menus

# Character Status Box
var status_block ## Connected status_block to UI

# Default State #
var state = "inactive"

# Vital Statistics #
var char_id
var character_name
var party_position
var last_party_position
var hp
var pp
var status
var level
var xp
var psi

# Maximum Vital Statistics #
var MAX_HP
var MAX_PP

#Battle Statistics
var offense
var defense
var speed
var guts
var vitality
var iq
var luck

## Equipment Slots ##
var EQUIP_WEAPON
var EQUIP_BODY
var EQUIP_ARMS
var EQUIP_OTHER

var equipment = [] ## List of equipped by ID

## FOLLOWER LOGIC

## Tweak for asset size changes, should be == sprite.width / 2
## Party followers should maintain a similar width, or set manually
var position_offset = 16 ## Default Character Offset to Player

var player_trail = [] ## Tracks leader positional data
var player_last_pos = Vector2(0,0) ## Last position entered by player
var position_index = 0 ## Index to use against player_trail, modified by offset

var stats_set ## FLoading check for initializing stats

## Inventory ##

var inventory = [] ## Character inventory, loaded from game_data, changes are saved dynamically

var ready_for_input = false ## 1-frame delay for inputs to negate double-input

var skin ## Texture ## Loaded dynamically from game_data, can be changed
## Skin is saved to game_data on softsaves

var sort_index ## Used to mark sorting for custom sort algorithms

## Animation flags
var anim_position ## Current position to animate to

var last_type ## Last type before tweening

##############################
## CHARACTER INITIALIZATION ##
##############################

func _init():
	TYPE = "FOLLOWER" ##Default to Follower, is set to player by Party.
	MAP_SPEED = 70

func _ready():
	connect("party_position_update", self, "_party_position_update")

func data_init(character_id):
	char_id = game_data.CHARACTER_DATA[character_id]["char_id"]
	character_name = game_data.CHARACTER_DATA[character_id]["name"]
	party_position = game_data.CHARACTER_DATA[character_id]["party_position"]
	status = game_data.CHARACTER_DATA[character_id]["status"]
	level = game_data.CHARACTER_DATA[character_id]["level"]
	xp = game_data.CHARACTER_DATA[character_id]["xp"]
	hp = game_data.CHARACTER_DATA[character_id]["hp"]
	MAX_HP = game_data.CHARACTER_DATA[character_id]["max_hp"]
	pp = game_data.CHARACTER_DATA[character_id]["pp"]
	MAX_PP = game_data.CHARACTER_DATA[character_id]["max_pp"]
	offense = game_data.CHARACTER_DATA[character_id]["offense"]
	defense = game_data.CHARACTER_DATA[character_id]["defense"]
	speed = game_data.CHARACTER_DATA[character_id]["speed"]
	guts = game_data.CHARACTER_DATA[character_id]["guts"]
	vitality = game_data.CHARACTER_DATA[character_id]["vit"]
	iq = game_data.CHARACTER_DATA[character_id]["iq"]
	luck = game_data.CHARACTER_DATA[character_id]["luck"]
	EQUIP_WEAPON = game_data.CHARACTER_DATA[character_id]["weapon"]
	EQUIP_BODY = game_data.CHARACTER_DATA[character_id]["body"]
	EQUIP_ARMS = game_data.CHARACTER_DATA[character_id]["arms"]
	EQUIP_OTHER = game_data.CHARACTER_DATA[character_id]["other"]
	inventory = game_data.CHARACTER_DATA[character_id]["inventory"]
	equipment = game_data.CHARACTER_DATA[character_id]["equipment"]
	psi = game_data.CHARACTER_DATA[character_id]["psi"]
	skin = game_data.CHARACTER_DATA[character_id]["skin"]
	
	$psi.init_psi_nodes()
	refresh_equipment()
	
	$Sprite.texture = load(skin)
	
	## Party Position
	if party_position == 0:
		party_position = game_data.party_members.size() + 1
	if party_position > 1:
		is_following = true
	else:
		TYPE = "PLAYER"

func set_stats():
	## Follower Logic
	if is_following && get_tree().get_nodes_in_group("party")[0].leader: 
		position = get_tree().get_nodes_in_group("party")[0].leader.position + Vector2(0,-1)
		player_last_pos = get_tree().get_nodes_in_group("party")[0].leader.position
		last_pos = get_tree().get_nodes_in_group("party")[0].leader.position
		load_sprite_dir = get_tree().get_nodes_in_group("party")[0].leader.load_sprite_dir
		set_direction()
		$hitbox.monitoring = false
		$hitbox.monitorable = false
		$collider.disabled = true
	else:
		#Connects for player
		ui.connect("player_menu_opened", self, "_player_menu_opened")
		ui.connect("player_menu_closed", self, "_player_menu_closed")
	## Status Block Connection
	var block_to_load = "block_%s" % str(party_position)
	status_block = ui.get_node("status_blocks").get_node(block_to_load)
	## Init base stats on status_block
	status_block.init(character_name,hp,pp)
	status_block.show()
	## Loaded flag
	stats_set = true
	## Set position_trail 
	reset_position_trail_to_leader()

##############################
##     DELTA PROCESSES      ##
##############################

func _process(delta):
	if engine.DEBUG:
		debug_inputs()
	if !stats_set:
		set_stats()
	else:
		match state:
			"active":
				if TYPE != "NPC":
					if is_following:
						state_following()
					else:
						if ready_for_input:
							state_default()
						else:
							ready_for_input = true
					update_party_pos_loop()
				else:
					pass
			"inactive":
				ready_for_input = false
				stop_anim_on_inactive()
		status_loop()

##############################
## STATE LOOPS & SWITCHING  ##
##############################

func state_default():
	controls_loop()
	movement_loop()
	animation_handler_loop()
	sprite_dir_loop()

func state_following():
	follower_check_trail()
	movement_loop()
	animation_handler_loop()
	sprite_dir_loop()

func controls_loop(): ## ONLY AVAILABLE TO TYPE == PLAYER
	var UP = Input.is_action_pressed("ui_up")
	var RIGHT = Input.is_action_pressed("ui_right")
	var DOWN = Input.is_action_pressed("ui_down")
	var LEFT = Input.is_action_pressed("ui_left")

	move_dir.x = -int(LEFT) + int(RIGHT)
	move_dir.y = -int(UP) + int(DOWN)
	
	if Input.is_action_just_pressed("snes_a"):
		ui.open_player_menu(self)
		audio.get_node("sfx").play_sound(dict.sfx_id["[4]"])
	
	if Input.is_action_just_pressed("snes_l"):
		talkCheck()
	
	if Input.is_action_just_pressed("snes_r"):
		if get_tree().get_nodes_in_group("party")[0].party_members.size() > 1:
			get_tree().get_nodes_in_group("party")[0].begin_cycle_forward()
		else:
			switch_state("inactive")
			connect_text_box()
			ui.text_box().load_read("No one to switch with. [wait] [break] [end]", self)
	
	if Input.is_action_just_pressed("snes_b"):
		switch_state("inactive")
		audio.get_node("sfx").play_sound(dict.sfx_id["[4]"])
		ui.open_status_and_funds(self)

	# Force turn on wall
	## DOWN
	if Input.is_action_pressed("ui_down") && Input.is_action_pressed("ui_right") && test_move(transform, dir._down * 2):
		turn_sprite(dir._down, "right")
	elif Input.is_action_pressed("ui_down") && Input.is_action_pressed("ui_left")  && test_move(transform, dir._down_left * 2):
		turn_sprite(dir._down, "left")
	elif Input.is_action_pressed("ui_down")  && test_move(transform, dir._down_right * 2):
		turn_sprite(dir._down)
	## UP
	if Input.is_action_pressed("ui_up") && Input.is_action_pressed("ui_right") && test_move(transform, dir._up_right * 2):
		turn_sprite(dir._up, "right")
	elif Input.is_action_pressed("ui_up") && Input.is_action_pressed("ui_left")  && test_move(transform, dir._up_left * 2):
		turn_sprite(dir._up, "left")
	elif Input.is_action_pressed("ui_up")  && test_move(transform, dir._up * 2):
		turn_sprite(dir._up)
	## RIGHT
	if Input.is_action_pressed("ui_right") && Input.is_action_pressed("ui_up") && test_move(transform, dir._up_right * 2):
		turn_sprite(dir._right, "up")
	elif Input.is_action_pressed("ui_right") && Input.is_action_pressed("ui_down")  && test_move(transform, dir._down_right * 2):
		turn_sprite(dir._right, "down")
	elif Input.is_action_pressed("ui_right")  && test_move(transform, dir._right * 2):
		turn_sprite(dir._right)
	## LEFT
	if Input.is_action_pressed("ui_left") && Input.is_action_pressed("ui_up") && test_move(transform, dir._up_left * 2):
		turn_sprite(dir._left, "up")
	elif Input.is_action_pressed("ui_left") && Input.is_action_pressed("ui_down")  && test_move(transform, dir._down_left * 2):
		turn_sprite(dir._left, "down")
	elif Input.is_action_pressed("ui_left")  && test_move(transform, dir._left * 2):
		turn_sprite(dir._left)

func update_party_pos_loop(): ## Maintains party_position accuracy
	party_position = get_tree().get_nodes_in_group("party")[0].party_members.find(self) + 1
	if last_party_position != party_position:
		emit_signal("party_position_update")
	position_offset = int(party_position-1) * 14
	last_party_position = party_position

## Follower function loop :: Maintains player_trails for current character
func follower_check_trail():
	if player_last_pos != get_tree().get_nodes_in_group("party")[0].leader.position:
		
		position = player_trail[0+position_offset][0]
		move_dir = player_trail[0+position_offset][1]
		
		player_trail.push_front([get_tree().get_nodes_in_group("party")[0].leader.position, get_tree().get_nodes_in_group("party")[0].leader.move_dir])
		
	else:
		move_dir = Vector2(0,0)
	
	player_last_pos = get_tree().get_nodes_in_group("party")[0].leader.position

## Status Loop updates connected status block with current HP/PP
func status_loop():
	if status_block:
		
		status_block.get_node("name").text = character_name
		
		if hp > MAX_HP:
			hp = MAX_HP
		
		if pp > MAX_PP:
			pp = MAX_PP
		
		if hp <= 0:
			hp = 0
		
		if pp <= 0:
			pp = 0
		
		status_block.target_hp = hp
		status_block.target_pp = pp

func switch_state(newState):
	state = newState

##############################
##   PLAYER_MENU ACTIONS    ## ## Called from player_menu
##############################

func talk_to():
	if $hitbox.get_overlapping_areas().size() == 0:
		no_npc_check()
	else:
		for object in $hitbox.get_overlapping_areas():
			if object.get_parent().get("TYPE"):
				match object.get_parent().TYPE:
					"NPC":
						if object.SUB_TYPE == "ENEMY":
							pass
						else:
							NPC_talk(object.get_parent())
					_:
						no_npc_check()
			else:
				no_npc_check()

func check():
	if $hitbox.get_overlapping_areas().size() == 0:
		no_object_check()
	else:
		for object in $hitbox.get_overlapping_areas():
			if object.get_parent().get("TYPE"):
				match object.get_parent().TYPE:
					"giftbox":
						gift_box_check(object.get_parent())
					"inspection_box":
						inspection_box_check(object.get_parent())
					_:
						no_npc_check()
			else:
				no_npc_check()

func talkCheck(): # R || L Button
	if $hitbox.get_overlapping_areas().size() == 0:
		no_object_check()
	else:
		for object in $hitbox.get_overlapping_areas():
			handle_interaction(object.get_parent())

##################################
## OBJECT/INTERACTION HANDLING  ##
##################################

### WARNING ###
#Run before ineraction parses to one shot connect
#Failure to run below connection will result in stuck_textboxes
func connect_text_box():
	if !ui.text_box().is_connected("text_done", ui.text_box(), "_text_done"):
		ui.text_box().connect("text_done", ui.text_box(), "_text_done", [self], 4)

func handle_interaction(object):
	if object.get("TYPE"):
		match object.TYPE:
			"giftbox":
				gift_box_check(object)
			"inspection_box":
				inspection_box_check(object)
			"NPC":
				if object.SUB_TYPE == "ENEMY":
					pass
				else:
					NPC_talk(object.get_parent())
			_:
				pass
	else:
		no_object_check()

func no_object_check():
	switch_state("inactive")
	connect_text_box()
	ui.text_box().load_read("No problem here. [wait] [break] [end]", self)

func inspection_box_check(object):
	switch_state("inactive")
	connect_text_box()
	ui.text_box().load_read(object.command, self)

func NPC_talk(npc):
	switch_state("inactive")
	connect_text_box()
	npc.talk_to(self)

func no_npc_check():
	switch_state("inactive")
	connect_text_box()
	ui.text_box().load_read("Who are you talking to? [wait] [break] [end]", self)

### Treasure Interaction

func gift_box_check(giftbox):
	switch_state("inactive")
	connect_text_box()
	giftbox.interact(self)

##############################
## ANIMATION FLAGS/QUEUES   ##
##############################

func stop_anim_on_inactive():
	if state == "inactive":
		$anim.stop()

func turn_sprite(direction, angle = "none"):
	match direction:
		dir._right:
			if angle == "none":
				$Sprite.frame = 2
				$Sprite.flip_h = true
			elif angle == "up":
				$Sprite.frame = 7
				$Sprite.flip_h = true
			elif angle == "down":
				$Sprite.frame = 5
				$Sprite.flip_h = true
		dir._left:
			if angle == "none":
				$Sprite.frame = 2
				$Sprite.flip_h = false
			elif angle == "up":
				$Sprite.frame = 7
				$Sprite.flip_h = false
			elif angle == "down":
				$Sprite.frame = 5
				$Sprite.flip_h = false
		dir._up:
			if angle == "none":
				$Sprite.frame = 1
			elif angle == "right":
				$Sprite.frame = 7
				$Sprite.flip_h = true
			elif angle == "left":
				$Sprite.frame = 7
				$Sprite.flip_h = false
		dir._down:
			if angle == "none":
				$Sprite.frame = 0
				$Sprite.flip_h = true
			elif angle == "right":
				$Sprite.frame = 5
				$Sprite.flip_h = true
			elif angle == "left":
				$Sprite.frame = 5
				$Sprite.flip_h = false

func walk_in_dir(direction, distance):
	var tween_target = position + (direction * distance)
	last_type = TYPE
	TYPE = "NPC"
	$tween.connect("tween_completed", self, "_tween_over", [], 4) 
	$tween.interpolate_property(self, "position", position, tween_target, distance / 8, $tween.TRANS_LINEAR, $tween.EASE_IN_OUT)
	$tween.start()

func modulate_0():
	$tween.interpolate_property(self, "modulate", Color(1,1,1,1), Color(0,0,0,1), 1, $tween.TRANS_LINEAR, $tween.EASE_IN_OUT)
	$tween.start()

func modulate_1():
	$tween.interpolate_property(self, "modulate", Color(0,0,0,1), Color(1,1,1,1), 1, $tween.TRANS_LINEAR, $tween.EASE_IN_OUT)
	$tween.start()

func _tween_over(a,b):
	TYPE = last_type

#################################
## EQUIPMENT RELATED FUNCTIONS ##
#################################

func equip_item_from_goods(item):
	inventory.remove(inventory.find(item.DATA["ID"]))
	item.DATA["EQUIPPED"] = true
	equipment.append(item.DATA["ID"])
	emit_signal("equip_change")
	refresh_equipment()

func unequip_item_from_goods(item):
	equipment.remove(equipment.find(item.DATA["ID"]))
	for x in get_node("equipment").get_children():
		if x.DATA["EQUIP_TYPE"] == item.DATA["EQUIP_TYPE"]:
			x.queue_free()
	item.DATA["EQUIPPED"] = false
	inventory.append(item.DATA["ID"])
	emit_signal("equip_change")
	refresh_equipment()

#################################
## SIGNALS & RELATED FUNCTIONS ##
#################################

func _party_position_update():
	status_block_refresh()

func _player_menu_opened():
	switch_state("inactive")

func _player_menu_closed():
	status_block.last_hp = hp
	status_block.last_pp = pp
	switch_state("active")

## Status Block Refresh on party_position_update()

func status_block_refresh():
	if party_position == 0:
		status_block.hide()
	else:
		status_block.hide()
		var block_to_load = "block_%s" % str(party_position)
		status_block = ui.get_node("status_blocks").get_node(block_to_load)
		status_block.last_hp = hp
		status_block.last_pp = pp
		status_block.show()

##############################
##      MISCELLANIOUS       ##
##############################

func reset_position_trail_to_leader(forceVector = null):
	if forceVector:
		for x in (position_offset * engine.party_count_max):
			player_trail.push_front([forceVector, get_tree().get_nodes_in_group("party")[0].leader.move_dir])
	else:
		for x in (position_offset * engine.party_count_max):
			player_trail.push_front([get_tree().get_nodes_in_group("party")[0].leader.position, get_tree().get_nodes_in_group("party")[0].leader.move_dir])

func change_texture(resource):
	skin = resource
	$Sprite.texture = load(resource)

func refresh_equipment():
	var weapon_x = null
	var body_x = null
	var arms_x = null
	var other_x = null
	for x in equipment:
		var equip_instance = item.fetch_item(x)
		match equip_instance.DATA["EQUIP_TYPE"]:
			"WEAPON":
				weapon_x = equip_instance
			"BODY":
				body_x = equip_instance
			"ARMS":
				arms_x = equip_instance
			"OTHER":
				other_x = equip_instance
			_:
				equip_instance.queue_free()
	EQUIP_WEAPON = weapon_x
	EQUIP_BODY = body_x
	EQUIP_ARMS = arms_x
	EQUIP_OTHER = other_x

##############################
##    GAME_DATA RELATED     ## ## game_data is repsonsible for static data between hard saves
##############################

func extract_data():
	return {
		"char_id" : char_id,
		"name": character_name, 
		"party_position": party_position,
		"status": status,
		"level" : level,
		"xp" : xp,
		"hp" : hp,
		"max_hp": MAX_HP,
		"pp" : pp,
		"max_pp": MAX_PP,
		"offense": offense,
		"defense": defense,
		"speed": speed,
		"guts" : guts,
		"vit" : vitality,
		"iq" : iq,
		"luck": luck,
		"weapon": EQUIP_WEAPON,
		"body": EQUIP_BODY,
		"arms": EQUIP_ARMS,
		"other": EQUIP_OTHER,
		"inventory": inventory,
		"equipment": equipment,
		"psi" : psi,
		"skin": skin
	}

##############################
##        DEBUGGING         ##
##############################

func debug_inputs():
	if Input.is_action_just_pressed("toggle_player_debug"):
		DEBUG_MODE = !DEBUG_MODE
		print("Player Debug is: ", DEBUG_MODE)
	if DEBUG_MODE:
		if Input.is_action_just_pressed("debug_num_9"):
			print("------------\nBody: %s, Position: %s, State: %s, Type: %s\nCurrent Status Block: %s, Positon Offset: %s, x/y: %s, Trail[0]: %s" % [character_name, party_position, state, TYPE, status_block.name, position_offset, position, player_trail[0][0]])
			print_psi()
			print_equipment()
		if Input.is_action_just_pressed("debug_num_7"):
			modulate_0()
		if Input.is_action_just_pressed("debug_num_8"):
			modulate_1()

func print_psi():
	print(character_name, " has the following PSI:")
	var psi_list = ""
	for x in $psi.get_children():
		psi_list += x.psi_name + ", "
	print(psi_list)

func print_equipment():
	print(character_name, " has the following nodes in equipment: ")

	## PRINT NODE INFORMATION

	for x in get_node("equipment").get_children():
		print(x.DATA["NAME"], "Equipped?: ", x.DATA["EQUIPPED"])
	
	print("EQUIP SLOTS: ", EQUIP_WEAPON, EQUIP_BODY, EQUIP_ARMS, EQUIP_OTHER)
	
	## PRINT WEAPON SLOT DATA REFERENCED NODE DATA
	var weapon_name = "None"
	var body_name = "None"
	var arms_name = "None"
	var other_name = "None"
	
	if EQUIP_WEAPON != null:
		weapon_name = EQUIP_WEAPON.DATA["NAME"]
	if EQUIP_BODY != null:
		body_name = EQUIP_BODY.DATA["NAME"]
	if EQUIP_ARMS != null:
		arms_name = EQUIP_ARMS.DATA["NAME"]
	if EQUIP_OTHER != null:
		other_name = EQUIP_OTHER.DATA["NAME"]

	print("WEAPON : %s" % weapon_name)
	print("BODY : %s" % body_name)
	print("ARMS : %s" % arms_name)
	print("OTHER : %s" % other_name)
	