extends "res://ui/components/game_menus/menu_base.gd"

var last_entity # Last entity to open screen ( Not Character )

var char_index = 0 # Index for party member
var last_index = 0 # Last frames index ## Used to track changes
var stats_loaded = false

var anim_playing = false

func _ready():
	state = "inactive"

func _process(delta):
	match state:
		"active":
			arrow_anims()
			if ready_for_input:
				check_status()
				if !anim_playing:
					input()
			else:
				ready_for_input = true
		"inactive":
			pass

###########################
##         INPUT         ##
###########################

func input():
	## Left / Right movement
	if Input.is_action_just_pressed("ui_right"):
		if char_index + 1 <= get_tree().get_nodes_in_group("party")[0].party_members.size() - 1:
			audio.get_node("sfx").play_sound(dict.sfx_id["[7]"])
			char_index += 1
			$anim.connect("animation_finished", self, "_anim_over",[],4)
			$anim.play("box_right")
			anim_playing = true
		else:
			pass
	if Input.is_action_just_pressed("ui_left"):
		if char_index - 1 >= 0:
			audio.get_node("sfx").play_sound(dict.sfx_id["[7]"])
			char_index -= 1
			$anim.connect("animation_finished", self, "_anim_over",[],4)
			$anim.play("box_left")
			anim_playing = true
		else:
			pass
	
	## Exit Input
	if Input.is_action_just_pressed("snes_b"):
		audio.get_node("sfx").play_sound(dict.sfx_id["[7]"])
		close()

###########################
##         SIGNAL        ##
###########################

func _anim_over(a):
	anim_playing = false

###########################
##    Monitor Status     ##
###########################

func check_status():
	if stats_loaded == false || char_index != last_index:
		print("load")
		print(get_tree().get_nodes_in_group("party")[0].party_members[char_index])
		stat_update(get_tree().get_nodes_in_group("party")[0].party_members[char_index])
		ui.get_node("status_blocks").active_block = char_index + 1
		stats_loaded = true
		last_index = char_index
	else:
		pass

###########################
## OPEN / CLOSE COMMANDS ##
###########################

func open(opening_entity):
	show()
	reset_index()
	opening_entity.switch_state("inactive")
	last_entity = opening_entity
	switch_state("active")

func close():
	reset_index()
	hide()
	last_entity.switch_state("active")
	switch_state("inactive")
	ui.get_node("status_blocks").active_block = 0
	stats_loaded = false
	ready_for_input = false

###########################
##  ANIMATION HANDLERS   ##
###########################

func arrow_anims():
	if $anim.is_playing():
		pass
	else:
		$anim.play("arrow_flash")

###########################
##### STAT UPDATE     #####
###########################

func stat_update(party_member):
	
	var total_offense = total_offense(party_member)
	var total_defense = total_defense(party_member)
	
	$name.text = party_member.character_name
	$status/level.get_node("#").text = str(party_member.level)
	$status/hp.get_node("#").text = str(party_member.hp) + " / " + str(party_member.MAX_HP)
	$status/pp.get_node("#").text = str(party_member.pp) + " / " + str(party_member.MAX_PP)
	$status/xp.get_node("#").text = str(party_member.xp)
	$status/next_level.get_node("#").text = "null"
	$status/offense.get_node("#").text = str(total_offense)
	$status/defense.get_node("#").text = str(total_defense)
	$status/speed.get_node("#").text = str(party_member.speed)
	$status/guts.get_node("#").text = str(party_member.guts)
	$status/vitality.get_node("#").text = str(party_member.vitality)
	$status/iq.get_node("#").text = str(party_member.iq)
	$status/luck.get_node("#").text = str(party_member.luck)

func reset_index():
	char_index = 0
	last_index = 0

###########################
##   TOTAL CALCULATORS  ##
###########################

func total_offense(party_member):
	var offense = party_member.offense
	## WEAPON CHECK
	if party_member.EQUIP_WEAPON != null:
		if party_member.EQUIP_WEAPON.DATA.has("OFFENSE"):
			offense += party_member.EQUIP_WEAPON.DATA["OFFENSE"]
	## BODY CHECK
	if party_member.EQUIP_BODY != null:
		if party_member.EQUIP_BODY.DATA.has("OFFENSE"):
			offense += party_member.EQUIP_BODY.DATA["OFFENSE"]
	## ARMS CHECK
	if party_member.EQUIP_ARMS != null:
		if party_member.EQUIP_ARMS.DATA.has("OFFENSE"):
			offense += party_member.EQUIP_ARMS.DATA["OFFENSE"]
	## OTHER CHECK
	if party_member.EQUIP_OTHER != null:
		if party_member.EQUIP_OTHER.DATA.has("OFFENSE"):
			offense += party_member.EQUIP_OTHER.DATA["OFFENSE"]
	## Return calculated offense
	return offense

func total_defense(party_member):
	var defense = party_member.offense
	## WEAPON CHECK
	if party_member.EQUIP_WEAPON != null:
		if party_member.EQUIP_WEAPON.DATA.has("DEFENSE"):
			defense += party_member.EQUIP_WEAPON.DATA["DEFENSE"]
	## BODY CHECK
	if party_member.EQUIP_BODY != null:
		if party_member.EQUIP_BODY.DATA.has("DEFENSE"):
			defense += party_member.EQUIP_BODY.DATA["DEFENSE"]
	## ARMS CHECK
	if party_member.EQUIP_ARMS != null:
		if party_member.EQUIP_ARMS.DATA.has("DEFENSE"):
			defense += party_member.EQUIP_ARMS.DATA["DEFENSE"]
	## OTHER CHECK
	if party_member.EQUIP_OTHER != null:
		if party_member.EQUIP_OTHER.DATA.has("DEFENSE"):
			defense += party_member.EQUIP_OTHER.DATA["DEFENSE"]
	## Return calculated defense
	return defense

###########################
##### STATE SWITCHING #####
###########################

func switch_state(newState):
	state = newState

