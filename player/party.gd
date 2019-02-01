extends Node2D

## Debug vars, do not edit. MODE is changed via key_command :: See Docs

var DEBUG_MODE = false
var debug_active_id
var debug_sort_method

var party_members = [] ## Party memers as kinematic bodies within array
var leader ## Current party leader

var new_positions = []

signal loaded
signal sort_finished
signal cycle_forwards_done

## Animation flags

var shift_position_animate = false

func _ready():
	load_party(false) ## Set true to sort by char_id on load
	load_player_pos()

func _process(delta):
	animate_shift_position()
	blocks_visible_loop()
	if engine.DEBUG:
		debug_input()

##########################
## MAIN PARTY FUNCTIONS ##
##########################

## Load Party from Game Data
func load_party(should_sort = false):
	var party_to_load = game_data.party_members
	var members_to_add_as_child = []
	for i in game_data.party_members.size():
		var member_to_add = load("res://player/player.tscn").instance()
		if i == 0: # Designates first party member
			leader = member_to_add
			leader.get_node("camera").current = true
		member_to_add.data_init(party_to_load[i])
		party_members.append(member_to_add)
		members_to_add_as_child.append(member_to_add)
	members_to_add_as_child.invert()
	for i in members_to_add_as_child:
		get_parent().call_deferred("add_child",i)
	if should_sort:
		sort_party("char_id")
	emit_signal("loaded")

## Loads starting position from game_data load_position 
## load_position is updated by doors and scene transitions
func load_player_pos():
	if game_data.player_load_position != null:
		leader.position = game_data.player_load_position
	else:
		if get_parent().name == "Over":
			leader.position = get_parent().get_parent().default_load_position
		else:
			leader.position = Vector2(1600,400)

## Add Party Member by character id
func add_party_member(char_id):
	var already_exists
	for x in party_members:
		if x.char_id == char_id:
			already_exists = true
	if already_exists:
		print("Character already in party")
	else:
		var character_to_add = load("res://player/player.tscn").instance()
		party_members.append(character_to_add)
		character_to_add.modulate= Color(1,1,1,0)
		character_to_add.data_init(char_id)
		#character_to_add.position = leader.position
		character_to_add.switch_state("active")
		character_to_add.modulate= Color(1,1,1,1)
		print("Adding party member: %s to position: %s" % [character_to_add.character_name, character_to_add.party_position])
		get_parent().call_deferred("add_child",character_to_add)
		update_game_data_party()

## Remove Party Member by character id
func remove_party_member(char_id):
	for x in party_members:
		if x.char_id == char_id:
			if leader == x:
				if party_members.size() > 1:
					make_leader(party_members[1])
				else:
					print("Can't remove last party member")
					return
			## Remove 
			var to_rem = party_members.find(x)
			print("Removing party member: %s" % x.character_name) 
			party_members.remove(to_rem)
			x.queue_free()
			game_data.CHARACTER_DATA[char_id]["party_position"] = 0
			update_game_data_party()

## Blocks Visible Loop 
## Determines which status blocks to show
func blocks_visible_loop():
	for x in party_members:
		if x.status_block:
			if !x.status_block.is_visible():
				x.status_block.show()

## Scene Signals -- Switches state to active when scene has finished loading
## Unless scene determines otherwise.
## Scenes should remove active state on_load for cutscenes and re-supply state when needed.
func _scene_faded_in():
	for x in party_members.size():
		party_members[x].switch_state("active")

## Data extract -- Used to update game_data
## .. Not used...?
func extract_data():
	var char_id_list = []
	for x in party_members:
		char_id_list.append(x.char_id)
	return char_id_list

##########################
## Party Refreshing     ##
##########################

## Checks to make sure position[0] is deemed party leader.
## Should be called after party sorting or modifications
func check_leader():
	make_leader(party_members[0])
	for x in party_members:
		if x != leader:
			x.TYPE = "FOLLOWER"
			x.get_node("camera").current = false
			x.is_following = true
			x.get_node("hitbox").monitoring = false
			x.get_node("hitbox").monitorable = false
			x.get_node("collider").disabled = true

func force_leader(force): #Force a leader
	make_leader(force)
	for x in party_members:
		if x != leader:
			x.TYPE = "FOLLOWER"
			x.get_node("camera").current = false
			x.is_following = true
			x.get_node("hitbox").monitoring = false
			x.get_node("hitbox").monitorable = false
			x.get_node("collider").disabled = true

## Sets leader, sub_function of check_leader
## Should not need called directly outside of remove_char()
## Necessary in remove_char to change leader before removing leader entity
func make_leader(party_member):
	leader = party_member
	#leader.get_node("camera").smoothing_enabled = true
	leader.get_node("camera").current = true
	leader.is_following = false
	leader.TYPE = "PLAYER"
	leader.get_node("hitbox").monitoring = true
	leader.get_node("hitbox").monitorable = true
	leader.get_node("collider").disabled = false


## Resets position trail to leader position
func reset_position_trail_to_leader():
	for x in party_members:
		x.reset_position_trail_to_leader()

##########################
## Game Data Pushing    ##
##########################

func update_game_data_party():
	game_data.party_members.clear()
	for x in party_members:
		game_data.party_members.append(x.char_id)
	if engine.DEBUG && DEBUG_MODE:
		print("game_data party_members updated: ", game_data.party_members)
	game_data.update_party_pos()

##########################
## Party Sorting        ##
##########################

func sort_party(method):
	match method:
		"char_id":
			connect("sort_finished", self, "_sort_finished", [], 4)
			party_members.sort_custom(self, "sort_by_char_id")
			emit_signal("sort_finished")
		"cycle_forwards":
			connect("sort_finished", self, "_sort_finished", [], 4)
			sort_by_cycle_forwards()
			emit_signal("sort_finished")
	
	if DEBUG_MODE:
		print("Sorting party by : %s" % method)
		var new_order_string = ""
		for x in party_members:
			new_order_string += (x.character_name + " ")
		print("New party order: %s" % new_order_string)

func sort_by_cycle_forwards(): ## Call begin_cycle_forwards() to animate cycle.
	print("------------")
	for x in party_members:
		var index = party_members.find(x)
		if index - 1 < 0:
			x.sort_index = party_members.size() - 1
			x.position = new_positions[x.sort_index][0]
			x.position_offset = new_positions[x.sort_index][1]
			x.player_trail = new_positions[x.sort_index][2]
			#print(x.character_name + " to the rear position: " + str(new_positions[x.sort_index][0]) )
		else:
			x.sort_index = index - 1
			x.position = new_positions[x.sort_index][0]
			x.position_offset = new_positions[x.sort_index][1]
			x.player_trail = new_positions[x.sort_index][2]
			#print(x.character_name + " moving forwards to " + str(new_positions[x.sort_index][0]))
	party_members.sort_custom(self, "sort_by_sort_index")

static func sort_by_char_id(a, b):
	if a.char_id < b.char_id:
		return true
	return false

static func sort_by_sort_index(a, b):
	if a.sort_index < b.sort_index:
		return true
	return false

func _sort_finished():
	check_leader()
	update_game_data_party()
	for x in party_members:
		x.switch_state("active")

##########################
## SORTING ANIMATION    ## ## Called Pre Sort Function to set positions
##########################

func begin_cycle_forward(): ## Call to cycle forward
	if game_data.party_members.size() > 1:
		connect("cycle_forwards_done", self, "_cycle_forwards_done", [], 4)
		new_positions.clear()
		force_leader(party_members[1])
	
		for x in party_members:
			new_positions.append([x.position, x.position_offset, x.player_trail])
			x.TYPE = "NPC"
		
		var i = 1
		
		for x in party_members:
			if x.party_position == 1:
				x.anim_position = new_positions[new_positions.size() - 1][0]
			else:
				x.anim_position = new_positions[x.party_position - 2][0]
			#print("FIRST: %s moving to: %s " % [x.character_name, str(x.anim_position)])
			i += 1
		shift_position_animate = true
	else:
		pass

func animate_shift_position():
	if shift_position_animate == true:
		var i = 0
		for x in party_members:
			if x.get_position().distance_to(x.anim_position) > 1:
				var direction = x.anim_position - x.position
				x.move_and_slide(direction.normalized() * ( x.MAP_SPEED * .5 ), Vector2(0,0))
			else:
				i += 1
				if i == party_members.size():
					var direction =  (party_members[party_members.size()-1].position - party_members[0].position).normalized()
					party_members[0].turn_sprite(direction)
					
					shift_position_animate = false
					emit_signal("cycle_forwards_done")

func _cycle_forwards_done():
	sort_party("cycle_forwards")
	pass

##########################
## OTHER PARTY FUNCTIONS ##
##########################

func check_inv_for_space(): ## Returns party member object that has space
	var inv_with_space = null
	for x in party_members:
		if x.inventory.size() < 14:
			inv_with_space = x
			return inv_with_space

##########################
##   DEBUG FUNCTIONS    ##
##########################

func debug_input():
	var print_out = false
	if Input.is_action_just_pressed("toggle_party_debug"): # SHIFT+1
		DEBUG_MODE = !DEBUG_MODE
		printerr("!# Toggle Party Debug: %s #!" % DEBUG_MODE)
		if DEBUG_MODE:
			print("active_id set to 0, sort method to by char_id")
			debug_sort_method = "char_id"
			debug_active_id = 0
	if DEBUG_MODE:
		
		## ANIM DEBUG, PARTY POS 2
		
		if Input.is_action_pressed("debug_secondary_up"):
			party_members[1].position += Vector2(0,-1)
		if Input.is_action_pressed("debug_secondary_down"):
			party_members[1].position += Vector2(0,1)
		if Input.is_action_pressed("debug_secondary_right"):
			party_members[1].position += Vector2(1,0)
		if Input.is_action_pressed("debug_secondary_left"):
			party_members[1].position += Vector2(-1,0)
		
		## Add / Rem Active ID
		
		if Input.is_action_just_pressed("debug_num_1"):
			add_party_member(debug_active_id)
		if Input.is_action_just_pressed("debug_num_2"):
			remove_party_member(debug_active_id)
		if Input.is_action_just_pressed("debug_num_3"):
			sort_party("cycle_forwards")
		
		if Input.is_action_just_pressed("debug_num_4"):
			begin_cycle_forward()
		
		## Sorting Debug
		
		if Input.is_action_just_pressed("debug_alt_0"):
			debug_sort_method = "char_id"
			print_out = true
		if Input.is_action_just_pressed("debug_alt_1"):
			debug_sort_method = "char_id_to_front"
			print_out = true
		if Input.is_action_just_pressed("debug_alt_2"):
			debug_sort_method = "char_id_to_rear"
			print_out = true
		
		if Input.is_action_just_pressed("debug_num_0"):
			sort_party(debug_sort_method)
		
		## Set Active IDs
		
		if Input.is_action_just_pressed("debug_ctr_0"):
			debug_active_id = 0
			print_out = true
		if Input.is_action_just_pressed("debug_ctr_1"):
			debug_active_id = 1
			print_out = true
		if Input.is_action_just_pressed("debug_ctr_2"):
			debug_active_id = 2
			print_out = true
		if Input.is_action_just_pressed("debug_ctr_3"):
			debug_active_id = 3
			print_out = true
		if Input.is_action_just_pressed("debug_ctr_4"):
			debug_active_id = 4
			print_out = true
		if Input.is_action_just_pressed("debug_ctr_5"):
			debug_active_id = 5
			print_out = true
		if Input.is_action_just_pressed("debug_ctr_6"):
			debug_active_id = 6
			print_out = true
		if Input.is_action_just_pressed("debug_ctr_7"):
			debug_active_id = 7
			print_out = true
		if Input.is_action_just_pressed("debug_ctr_8"):
			debug_active_id = 8
			print_out = true
		if Input.is_action_just_pressed("debug_ctr_9"):
			debug_active_id = 9
			print_out = true
		
		if print_out:
			var line_1 = "Active debug_char_id switched to: %s" % debug_active_id
			var line_2 = "Party debug sort method set to: %s" % debug_sort_method
			print("!----- Party Debug Settings -----!\n%s\n%s" % [line_1, line_2])
		
		if Input.is_action_just_pressed("debug_num_9"):
			print("----- Party Debug Print START -----")
			var ids = []
			for x in party_members:
				ids.append(x.char_id)
			print("ID's in party: " , ids)
			print("Leader Name: %s, Leader State: %s, Leader Type: %s" % [leader.character_name, leader.state, leader.TYPE])
			for x in game_data.CHARACTER_DATA:
				print(x.name, " is at pos: ", x["party_position"])
			print("----- Party Debug Print END -----")