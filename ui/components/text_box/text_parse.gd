extends "res://ui/components/game_menus/menu_base.gd"

var box_type = "null"

var TEXT_DEBUG = false ## Remove ui form auto-load for isolated testing
var PARSE_DEBUG = false
var ISOLATE_AND_DEBUG_TEXT_BOX = false # True for t_string tests also put TEXT_DEBUG on

## TEXT_BOX Settings

var TEXT_AUTO_WAIT = false # May still need some debugging

## Sub-state

var sub_state = "null"

## SFX Module

var sfx = null
var secondary_sfx = null

## Default delay

var default_delay = 15

# Most Recently Calling Entity

var last_entity = null

## Text Command Codes ##

const DOT = "@" # Prints EB Bullet
const LINE_BREAK = "[break]" # No new box line break || Earthbound's [00] Code
const WAIT = "[wait]" # Waits for player to press A
const END = "[end]" # Ends parsing and emits signal: "done" || Earthbound's [02] Code
const SFX = "[sfx]" # Followed by SFX ID from dict.sfx_id [0]
const DELAY = "[d]" # Followed by frames to wait
const DEFAULT_DELAY = "[dd]" # Sets delay to default delay
const CHOICE = "[choice]"
const FLAG_ON = "[flag_on]" # Toggle flag id on e.g [flag_on] [1]
const FLAG_OFF = "[flag_off]" # Toggle flag id off e.g [flag_off] [1]
const PAUSE = "[pause]" # Ends parsing until switched back.

## Item Command Codes & Signals

const ITEM_HEAL = "[item_heal]" # Emits item signal to heals target the last calculated item restoration amount.

## PSI Command Codes & Signals

const PSI_HEAL = "[psi_heal]" ## Same as item heal but for psi
const PSI_DEPLETE = "[psi_deplete]" # Reduced PP by PP cost

## Box command codes

const CLOSE_BOX = "[close_box]" # Closes connected gift box

## Print character names

const CHAR_0 = "[char_0]"
const CHAR_1 = "[char_1]"
const CHAR_2 = "[char_2]"
const CHAR_3 = "[char_3]"

## Signals

signal item_heal
signal psi_heal
signal psi_deplete
signal close_box
signal choice_yes
signal choice_no

## Parsing Vars

var pixels_needed = 0

var pixels_per_line = 134 # Pixels left after tab/dot
var line_pixels_used = 0

var line_counter = 0
var lines_to_wait = 3

## Spacing constants

var char_space = 1
var tab_space = 9

## Loaded Command & Command positioning

var command_string_array = []
var command_string_position = 0

## Word positioning

var word_to_print = []
var word_char_count = 0

## Text flags

var last_word_printed = false
var para_space = true
var line_space = true

## Print Speed Settings

const parse_speed = {"slow": 2, "normal": 1, "fast": 0}
var frames_per_char = parse_speed["fast"]
var frames_since_print = 0

## Delay settings
var delay_frames

## yes/no flags

var yes_bool = true

## Test string

var t_string_1 = """Since it's a really [pizza] big pizza, everyone can recover about 240 HP when eaten. Since it's a really big pizza, everyone can recover about 240 HP when eaten. Since it's a really big pizza, everyone can recover about 240 HP when eaten. Since it's a really big pizza, everyone can recover about 240 HP when eaten."""

var t_string_2 = """Don't worry Henry. [wait] [break]
Someday we will get away from here. [wait] [break]
@ I promise.
"""

var t_string_3 = """Ness ate the hamburger. [sfx] [0] [wait] [break]
Ness recovered 23 HP. [sfx] [1]
"""

var t_string_4 = """Hey there [dd] . [dd] . [dd] . [dd] [wait] [break] How's it going? """

var t_string_5 = """Hi Ness. Hi Ness? Hi Ness! [break] Hi [char_0] . Hi [char_0] ? Hi [char_0] !"""

var t_string_6 = """Come on [char_0] ! [wait] [break] @ Don't keep [char_0] waiting. [wait] [end] """

func _init():
	should_hide = false
	state = "active"
	sub_state = "parsing"

func _ready():
	load_sfx_players()
	load_command(t_string_6)

func _process(delta):
	match state:
		"active":
			match sub_state:
				"parsing":
					parsing_loop()
				"waiting":
					waiting_loop()
				"auto_para_wait":
					auto_para_wait()
				"delay":
					delay_loop()
				"choice":
					choice_loop()
				"paused":
					paused()
		"inactive":
			pass

func parsing_loop():
	if last_word_printed || command_string_position == 0:
		parse_next_command()
	else:
		word_print_loop()

func waiting_loop():
	if Input.is_action_just_pressed("text_continue"):
		switch_sub_state("parsing")
		line_counter = -1

func paused():
	pass

func auto_para_wait():
	if Input.is_action_just_pressed("text_continue"):
		switch_sub_state("parsing")
		line_counter = -1
		line_break(pixels_needed)

func delay_loop():
	if delay_frames > 0:
		delay_frames -= 1
	else:
		switch_sub_state("parsing")

func choice_loop():
	if !$yes.is_visible():
		$yes.show()
	if !$no.is_visible():
		$no.show()
	if yes_bool:
		$yes/yes_arrow.show()
		$no/no_arrow.hide()
	else:
		$no/no_arrow.show()
		$yes/yes_arrow.hide()
	
	if Input.is_action_just_pressed("ui_right"):
		yes_bool = false
		audio.get_node("sfx").play_sound(dict.sfx_id["[4]"])
	if Input.is_action_just_pressed("ui_left"):
		audio.get_node("sfx").play_sound(dict.sfx_id["[5]"])
		yes_bool = true
	if Input.is_action_just_pressed("text_continue"):
		if yes_bool:
			emit_signal("choice_yes")
			reset_choice_state()
		else:
			emit_signal("choice_no")
			reset_choice_state()
	
	
	if arrow_blink_rate < arrow_blink_rate_init:
		arrow_blink_rate += 1
	else: ## Condense to group and for loop
		if $no.get_node("no_arrow").frame == 0:
			$no.get_node("no_arrow").frame = 1
		else:
			$no.get_node("no_arrow").frame = 0
		if $yes.get_node("yes_arrow").frame == 0:
			$yes.get_node("yes_arrow").frame = 1
		else:
			$yes.get_node("yes_arrow").frame = 0
		arrow_blink_rate = 0

func reset_choice_state():
	$yes.hide()
	$no.hide()

## Non commands are forwarded to the print queue via parse_word()
func parse_next_command():
	if command_string_position < command_string_array.size():
		var cc = command_string_array[command_string_position]
		#Place bullet on text start
		if command_string_position == 0:
			$text.append_bbcode("[img]res://ui/assets/print_icon.png[/img]")
		
		match cc:
			## Parsing
			DOT:
				dot_break()
			LINE_BREAK:
				line_break()
			WAIT:
				switch_sub_state("waiting")
			PAUSE:
				pause()
			DELAY:
				var delay_time = int(command_string_array[command_string_position + 1].replace("[", "").replace("]", ""))
				delay_frames = delay_time
				switch_sub_state("delay")
			DEFAULT_DELAY:
				delay_frames = default_delay
				switch_sub_state("delay")
			CHOICE:
				yes_bool = true
				switch_sub_state("choice")
			## SFX
			SFX:
				play_sfx(command_string_array[command_string_position + 1])
			# HEALING
			ITEM_HEAL:
				connect("item_heal", last_entity, "item_heal", [], 4)
				emit_signal("item_heal")
			PSI_HEAL:
				connect("psi_heal", last_entity, "psi_heal", [], 4)
				emit_signal("psi_heal")
			PSI_DEPLETE:
				connect("psi_deplete", last_entity, "psi_deplete", [], 4)
				emit_signal("psi_deplete")			
			## Giftbox Interaction
			CLOSE_BOX: ## Used to close box when no room in inv
				emit_signal("close_box")
			## NAME PRINTS
			CHAR_0:
				insert_char_name(0)
			CHAR_1:
				insert_char_name(1)
			CHAR_2:
				insert_char_name(2)
			CHAR_3:
				insert_char_name(3)
			## FLAG MARKING
			FLAG_ON:
				var flag = int(command_string_array[command_string_position + 1].replace("[", "").replace("]", ""))
				toggle_flag("on", flag)
			FLAG_OFF:
				var flag = int(command_string_array[command_string_position + 1].replace("[", "").replace("]", ""))
				toggle_flag("off", flag)
			## END
			END:
				_end()
			_:	
				if !cc: # Catches \n and ignores
					pass
				elif cc[0] != "[" :
					parse_word(cc)
	else:
		pass # END HERE?
		
	command_string_position += 1

## Used to parse a non command and send to print ##
func parse_word(cc):
	last_word_printed = false
	pixels_needed = 0
	
	if TEXT_DEBUG && PARSE_DEBUG:
		print("------------------")
		print("Debug log for word: ", cc)
	
	## Get characters in command
	var cc_chars = []
	for char_x in cc:
		cc_chars.append(char_x)
	
	## Get pixels needed for word
	var iterations = cc_chars.size()
	var i = 1
	## Adds character pixels except at last char and space " "
	word_to_print = [] ## Set up string_array for printing
	for char_x in cc_chars:
		if TEXT_DEBUG && PARSE_DEBUG:
			print("Pixels in char: %s , :: %s" % [char_x, dict.char_size[char_x]])
		pixels_needed += dict.char_size[char_x]
		if i < iterations:
			pixels_needed += char_space
			word_to_print.append(char_x)
		else:
			word_to_print.append(char_x + " ") ## Space appeMynd for word-end
			pixels_needed += dict.char_size[" "]
		i += 1
	space_check()

## Sets flags for if space is available for the word_to_print
## Put line breaks here etc
func space_check():
	
	if line_pixels_used + pixels_needed < pixels_per_line:
		line_space = true
		line_pixels_used += pixels_needed
	else:
		if para_space:
			line_break(pixels_needed)

## After being sent to queue
func word_print_loop():
	if line_space:
		if frames_since_print < frames_per_char:
			frames_since_print += 1
		else:
			print_char()
			frames_since_print = 0 
	else:
		space_check()

func print_char():
	if word_char_count == 0:
		sfx.play()
	if word_char_count < word_to_print.size():
		$text.append_bbcode(word_to_print[word_char_count])
		word_char_count += 1
	else:
		if TEXT_DEBUG && PARSE_DEBUG:
			print("Finished printing: ", word_to_print)
		word_char_count = 0
		last_word_printed = true

## Text_box alginment specific commands

func line_break(pixels = 0):
	if line_counter + 1 < lines_to_wait || TEXT_AUTO_WAIT == false:
		if command_string_array[command_string_position + 1] != DOT:
			$text.append_bbcode("\n	")
			line_pixels_used = pixels
			line_counter += 1
		else:
			pass
	else:
		switch_sub_state("auto_para_wait")

func dot_break(pixels = 0):
	$text.append_bbcode("\n[img]res://ui/assets/print_icon.png[/img]")
	line_pixels_used = pixels
	line_counter += 1

func insert_char_name(id):
	var char_name = game_data.CHARACTER_DATA[id]["name"]
	var nextcc = command_string_array[command_string_position + 1]
	match nextcc:
		",":
			char_name += ","
			command_string_array[command_string_position + 1] = char_name
		".":
			char_name += "."
			command_string_array[command_string_position + 1] = char_name
		"?":
			char_name += "?"
			command_string_array[command_string_position + 1] = char_name
		"!":
			char_name += "!"
			command_string_array[command_string_position + 1] = char_name
		_:
			command_string_array.insert(command_string_position + 1, char_name)

func toggle_flag(toggle, id):
	match toggle:
		"on":
			print("%s toggled on" % id)
			flags.flags[id] = true
		"off":
			print("%s toggled off" % id)
			flags.flags[id] = false

## Load and reset command functions ##

func load_command(command): # Must be called prior to parsing, removes line breaks
	_reset()
	var loading_text = command.replace("\n", " ")
	command_string_array = loading_text.split(" ")

func read_command(calling_entity, close_on_end = false):
	show()
	switch_state("active")
	switch_sub_state("parsing")
	last_entity = calling_entity

#One liner for above functions
func load_read(command, calling_entity):
	load_command(command)
	read_command(calling_entity)

func _reset():
	command_string_array = null
	command_string_position = 0
	$text.clear()
	line_pixels_used = 0

## State switchers ##

func switch_state(newState):
	state = newState

func switch_sub_state(newState):
	sub_state = newState

func pause():
	switch_sub_state("pause")

func resume():
	switch_sub_state("parsing")

## SFX Handling ##

func load_sfx_players():
	sfx = AudioStreamPlayer.new()
	sfx.stream = load("res://sound/fx/text.wav")
	sfx.volume_db = -22
	self.add_child(sfx)
	load_secondary_sfx_player()

func load_secondary_sfx_player():
	secondary_sfx = AudioStreamPlayer.new()
	secondary_sfx.stream = load("res://sound/fx/text.wav")
	secondary_sfx.volume_db = -22
	self.add_child(secondary_sfx)

func play_sfx(sfx_id):
	secondary_sfx.stream = load(dict.sfx_id[sfx_id])
	secondary_sfx.play()

## Signal Emitters
func _end():
	emit_signal("text_done")