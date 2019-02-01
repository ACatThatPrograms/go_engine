extends TextureRect

var state = "active" # Will only update when active

var block_name = "default_block"

## SFX

var sfx = null

## Status Flags

var collapsed = null

## Animation counters / limits

var hp_anims_needed_to_target = 0
var hp_anims_played = 0

var pp_anims_needed_to_target = 0
var pp_anims_played = 0

var hp_frames = 0
var pp_frames = 0

## Frame Flags

var flag_counter_max = 4

#### HP FLAGS

var hp_up_tens_flag = false
var hp_up_tens_flag_counter = 0

var hp_down_tens_flag = false
var hp_down_tens_flag_counter = 0

var hp_up_hundreds_flag = false
var hp_up_hundreds_flag_counter = 0

var hp_down_hundreds_flag = false
var hp_down_hundreds_flag_counter = 0

#### PP FLAGS

var pp_up_tens_flag = false
var pp_up_tens_flag_counter = 0

var pp_down_tens_flag = false
var pp_down_tens_flag_counter = 0

var pp_up_hundreds_flag = false
var pp_up_hundreds_flag_counter = 0

var pp_down_hundreds_flag = false
var pp_down_hundreds_flag_counter = 0

## Frame Timing

var frames_per_update = 1
var frames_waited = 0

## Frame # Dictionary

var number_frames = {
	0 : 0,
	1 : 4*1,
	2 : 4*2,
	3 : 4*3,
	4 : 4*4,
	5 : 4*5,
	6 : 4*6,
	7 : 4*7,
	8 : 4*8,
	9 : 4*9
}

## Stats

var set_hp
var set_pp
var target_hp
var target_pp
var last_hp
var last_pp

func _ready():
	load_base_stats()
	load_sfx_players()

func _process(delta):
	match state:
		"active":
			if frames_waited < frames_per_update:
				frames_waited += 1
			else:
				update_status_block_loop()
				frames_waited = 0
		"inactive":
			pass

func update_status_block_loop():
		check_death()
		update_hp()
		update_pp()

func check_death():
	if set_hp == 0 && target_hp == 0 && last_hp == 0 && !collapsed:
		play_sfx("[3]")
		collapsed = true
	elif target_hp > 0:
		collapsed = false

func update_hp():
	
	hp_tens_hundreds_flag()
	
	hp_hide_zeroes()
	
	if target_hp <= 0:
		target_hp = 0
	
	if last_hp < target_hp:
		if hp_anims_needed_to_target != (target_hp - last_hp) * 4:
			hp_anims_played = 0
			hp_anims_needed_to_target = (target_hp - last_hp) * 4
		roll_hp_up()
		if hp_frames < 3:
			hp_frames += 1
		else:
			last_hp += 1
			hp_frames = 0
		if last_hp > 999:
			set_hp_roller(999)
			
	elif last_hp > target_hp:
		if hp_anims_needed_to_target != ((target_hp - last_hp) * 4) * -1:
			hp_anims_played = 0
			hp_anims_needed_to_target = ((target_hp - last_hp) * 4) * -1
		roll_hp_down()
		if hp_frames < 3:
			hp_frames += 1
		else:
			last_hp -= 1
			hp_frames = 0
	
	elif last_hp == target_hp:
		set_hp = last_hp
		if set_hp < 1000:
			set_hp_roller()
	
	last_hp = last_hp

func update_pp():
	
	pp_tens_hundreds_flag()
	
	pp_hide_zeroes()
	
	if target_pp <= 0:
		target_pp = 0
	
	if last_pp < target_pp:
		if pp_anims_needed_to_target != (target_pp - last_pp) * 4:
			pp_anims_played = 0
			pp_anims_needed_to_target = (target_pp - last_pp) * 4
		roll_pp_up()
		if pp_frames < 3:
			pp_frames += 1
		else:
			last_pp += 1
			pp_frames = 0
		if last_pp > 999:
			set_pp_roller(999)
			
	elif last_pp > target_pp:
		if pp_anims_needed_to_target != ((target_pp - last_pp) * 4) * -1:
			pp_anims_played = 0
			pp_anims_needed_to_target = ((target_pp - last_pp) * 4) * -1
		roll_pp_down()
		if pp_frames < 3:
			pp_frames += 1
		else:
			last_pp -= 1
			pp_frames = 0
	
	elif last_pp == target_pp:
		set_pp = last_pp
		if set_pp < 1000:
			set_pp_roller()
	
	last_pp = last_pp

func hp_tens_hundreds_flag():
	
	## HP HUNDREDS FLAGS
	
	if hp_up_hundreds_flag:
		if hp_up_hundreds_flag_counter < flag_counter_max:
			if get_node("hp_100").frame + 1 == 40:
				get_node("hp_100").frame = 0
			else:
				get_node("hp_100").frame += 1
			hp_up_hundreds_flag_counter += 1
		else:
			hp_up_hundreds_flag = false
			hp_up_hundreds_flag_counter = 0
	
	if hp_down_hundreds_flag:
		if hp_down_hundreds_flag_counter < flag_counter_max:
			if get_node("hp_100").frame - 1 == -1:
				get_node("hp_100").frame = 39
			else:
				get_node("hp_100").frame -= 1
			hp_down_hundreds_flag_counter += 1
		else:
			hp_down_hundreds_flag = false
			hp_down_hundreds_flag_counter = 0
	
	## HP TENS FLAGS
	
	if hp_up_tens_flag:
		if hp_up_tens_flag_counter < flag_counter_max:
			if get_node("hp_10").frame + 1 == 40:
				get_node("hp_10").frame = 0
				hp_up_hundreds_flag = true
			else:
				get_node("hp_10").frame += 1
			hp_up_tens_flag_counter += 1
		else:
			hp_up_tens_flag = false
			hp_up_tens_flag_counter = 0
			
	if hp_down_tens_flag:
		if hp_down_tens_flag_counter < flag_counter_max:
			if get_node("hp_10").frame -1 == -1:
				get_node("hp_10").frame = 39
				hp_down_hundreds_flag = true
			else:
				get_node("hp_10").frame -= 1
			hp_down_tens_flag_counter += 1
		else:
			hp_down_tens_flag = false
			hp_down_tens_flag_counter = 0

func pp_tens_hundreds_flag():
	
	## PP HUNDREDS FLAGS
	
	if pp_up_hundreds_flag:
		if pp_up_hundreds_flag_counter < flag_counter_max:
			if get_node("pp_100").frame + 1 == 40:
				get_node("pp_100").frame = 0
			else:
				get_node("pp_100").frame += 1
			pp_up_hundreds_flag_counter += 1
		else:
			pp_up_hundreds_flag = false
			pp_up_hundreds_flag_counter = 0
	
	if pp_down_hundreds_flag:
		if pp_down_hundreds_flag_counter < flag_counter_max:
			if get_node("pp_100").frame - 1 == -1:
				get_node("pp_100").frame = 39
			else:
				get_node("pp_100").frame -= 1
			pp_down_hundreds_flag_counter += 1
		else:
			pp_down_hundreds_flag = false
			pp_down_hundreds_flag_counter = 0
	
	## PP TENS FLAGS
	
	if pp_up_tens_flag:
		if pp_up_tens_flag_counter < flag_counter_max:
			if get_node("pp_10").frame + 1 == 40:
				get_node("pp_10").frame = 0
				pp_up_hundreds_flag = true
			else:
				get_node("pp_10").frame += 1
			pp_up_tens_flag_counter += 1
		else:
			pp_up_tens_flag = false
			pp_up_tens_flag_counter = 0
			
	if pp_down_tens_flag:
		if pp_down_tens_flag_counter < flag_counter_max:
			if get_node("pp_10").frame -1 == -1:
				get_node("pp_10").frame = 39
				pp_down_hundreds_flag = true
			else:
				get_node("pp_10").frame -= 1
			pp_down_tens_flag_counter += 1
		else:
			pp_down_tens_flag = false
			pp_down_tens_flag_counter = 0

#### HP ROLLERS ####

func roll_hp_up():
	if hp_anims_played < hp_anims_needed_to_target:
		if get_node("hp_1").frame + 1 == 40:
			get_node("hp_1").frame = 0
			hp_up_tens_flag = true
		else:
			get_node("hp_1").frame += 1
		
	hp_anims_played += 1

func roll_hp_down():
	if hp_anims_played < hp_anims_needed_to_target:
		if get_node("hp_1").frame - 1 == -1 :
			get_node("hp_1").frame = 39
			hp_down_tens_flag = true		
		else:
			get_node("hp_1").frame -= 1
		
	hp_anims_played += 1

#### PP ROLLERS ####

func roll_pp_up():
	if pp_anims_played < pp_anims_needed_to_target:
		if get_node("pp_1").frame + 1 == 40:
			get_node("pp_1").frame = 0
			pp_up_tens_flag = true
		else:
			get_node("pp_1").frame += 1
		
	pp_anims_played += 1

func roll_pp_down():
	if pp_anims_played < pp_anims_needed_to_target:
		if get_node("pp_1").frame - 1 == -1 :
			get_node("pp_1").frame = 39
			pp_down_tens_flag = true		
		else:
			get_node("pp_1").frame -= 1
		
	pp_anims_played += 1

## Hide unused rollers

func hp_hide_zeroes():
	if last_hp >= 100:
		get_node("hp_100").show()
	else:
		get_node("hp_100").hide()
		
	if last_hp >= 10:
		get_node("hp_10").show()
	else:
		get_node("hp_10").hide()

func pp_hide_zeroes():
	if last_pp >= 100:
		get_node("pp_100").show()
	else:
		get_node("pp_100").hide()
		
	if last_pp >= 10:
		get_node("pp_10").show()
	else:
		get_node("pp_10").hide()

## Init Load Of Statistics and Roller Setters

func set_hp_roller(to_digit = null):
	var number_to_set
	
	if to_digit != null:
		number_to_set = to_digit
	else:
		number_to_set = set_hp
	
	var hp_digits = []
	var hp_parsed = []
	for x in str(number_to_set):
		hp_digits.append(x)
	
	if hp_digits.size() == 1:
		hp_parsed.append("null")
		hp_parsed.append("null")
		hp_parsed.append(hp_digits[0])
	elif hp_digits.size() == 2:
		hp_parsed.append("null")
		hp_parsed.append(hp_digits[0])
		hp_parsed.append(hp_digits[1])
	elif hp_digits.size() == 3:
		hp_parsed.append(hp_digits[0])
		hp_parsed.append(hp_digits[1])
		hp_parsed.append(hp_digits[2])
	
	if hp_parsed[0] != "null":
		get_node("hp_100").frame = number_frames[int(hp_parsed[0])]
	if hp_parsed[1] != "null":
		get_node("hp_10").frame = number_frames[int(hp_parsed[1])]
	if hp_parsed[2] != "null":
		get_node("hp_1").frame = number_frames[int(hp_parsed[2])]

func set_pp_roller(to_digit = null):
		
	var number_to_set
	
	if to_digit != null:
		number_to_set = to_digit
	else:
		number_to_set = set_pp
	
	var pp_digits = []
	var pp_parsed = []
	for x in str(number_to_set):
		pp_digits.append(x)
	
	if pp_digits.size() == 1:
		pp_parsed.append("null")
		pp_parsed.append("null")
		pp_parsed.append(pp_digits[0])
	elif pp_digits.size() == 2:
		pp_parsed.append("null")
		pp_parsed.append(pp_digits[0])
		pp_parsed.append(pp_digits[1])
	elif pp_digits.size() == 3:
		pp_parsed.append(pp_digits[0])
		pp_parsed.append(pp_digits[1])
		pp_parsed.append(pp_digits[2])
	
	if pp_parsed[0] != "null":
		get_node("pp_100").frame = number_frames[int(pp_parsed[0])]
	if pp_parsed[1] != "null":
		get_node("pp_10").frame = number_frames[int(pp_parsed[1])]
	if pp_parsed[2] != "null":
		get_node("pp_1").frame = number_frames[int(pp_parsed[2])]
		

func load_base_stats():
	
	## HP Parse
	
	var hp_digits = []
	var hp_parsed = []
	for x in str(set_hp):
		hp_digits.append(x)
	
	if hp_digits.size() == 1:
		hp_parsed.append("null")
		hp_parsed.append("null")
		hp_parsed.append(hp_digits[0])
	elif hp_digits.size() == 2:
		hp_parsed.append("null")
		hp_parsed.append(hp_digits[0])
		hp_parsed.append(hp_digits[1])
	elif hp_digits.size() == 3:
		hp_parsed.append(hp_digits[0])
		hp_parsed.append(hp_digits[1])
		hp_parsed.append(hp_digits[2])
	
	if hp_parsed[0] != "null":
		get_node("hp_100").frame = number_frames[int(hp_parsed[0])]
	if hp_parsed[1] != "null":
		get_node("hp_10").frame = number_frames[int(hp_parsed[1])]
	if hp_parsed[2] != "null":
		get_node("hp_1").frame = number_frames[int(hp_parsed[2])]
	
	#print("Loaded HP: ", hp_parsed)
	
	## PP Parse
	
	var pp_digits = []
	var pp_parsed = []
	for x in str(set_pp):
		pp_digits.append(x)
	
	if pp_digits.size() == 1:
		pp_parsed.append("null")
		pp_parsed.append("null")
		pp_parsed.append(pp_digits[0])
	elif pp_digits.size() == 2:
		pp_parsed.append("null")
		pp_parsed.append(pp_digits[0])
		pp_parsed.append(pp_digits[1])
	elif pp_digits.size() == 3:
		pp_parsed.append(pp_digits[0])
		pp_parsed.append(pp_digits[1])
		pp_parsed.append(pp_digits[2])
	
	if pp_parsed[0] != "null":
		get_node("pp_100").frame = number_frames[int(pp_parsed[0])]
	if pp_parsed[1] != "null":
		get_node("pp_10").frame = number_frames[int(pp_parsed[1])]
	if pp_parsed[2] != "null":
		get_node("pp_1").frame = number_frames[int(pp_parsed[2])]
		
	#print("Loaded PP: ", pp_parsed)

func debug_inputs():
	
	## HP Editing
	if Input.is_action_just_pressed("ui_up"):
		target_hp += 15
	if Input.is_action_just_pressed("ui_down"):
		target_hp -= 15
	if Input.is_action_just_pressed("ui_right"):
		target_hp += 45
	if Input.is_action_just_pressed("ui_left"):
		target_hp -= 45
	
	
	## PP Editing
	if Input.is_action_just_pressed("snes_a"):
		target_pp += 15
	if Input.is_action_just_pressed("snes_b"):
		target_pp -= 15
	if Input.is_action_just_pressed("snes_r"):
		target_pp += 45
	if Input.is_action_just_pressed("snes_l"):
		target_pp -= 45
	
	if Input.is_action_just_pressed("snes_y"):
		print("%s\nLast HP: %s, Last PP: %s\nTarget HP: %s, Target PP: %s " % [block_name, last_hp, last_pp, target_hp, target_pp])

## SFX Handling ##

func load_sfx_players():
	sfx = AudioStreamPlayer.new()
	sfx.stream = load("res://sound/fx/text.wav")
	sfx.volume_db = -22
	self.add_child(sfx)

func play_sfx(sfx_id):
	sfx.stream = load(dict.sfx_id[sfx_id])
	sfx.play()

## Must be called from player on scene start or ready on debug
func init(char_name,hp,pp):
	if has_node("name"):
		$name.text = char_name
	set_hp = hp
	set_pp = pp
	target_hp = set_hp
	target_pp = set_pp
	last_hp = set_hp
	last_pp = set_pp