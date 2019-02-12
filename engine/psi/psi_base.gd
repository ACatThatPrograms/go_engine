extends Node

var psi_name
var type
var sub_type
var level
var cost
var target
var amount
var description

## Last Entity
var last_entity

## Rec/Cost/Damage Amounts
var hp_rec
var pp_rec
var pp_cost

var active_caster
var target_to_heal

func _ready():
	pass

func fetch_psi(psi_id):
	
	var return_psi = set_up_psi(psi_id)
	
	return return_psi

func set_up_psi(id):
	var psi = get_script().new()
	
	psi.psi_name = dict.PSI[id]["name"]
	psi.type = dict.PSI[id]["type"]
	psi.sub_type = dict.PSI[id]["sub_type"]
	psi.level = dict.PSI[id]["level"]
	psi.cost = dict.PSI[id]["cost"]
	psi.target = dict.PSI[id]["target"]
	psi.amount = dict.PSI[id]["amount"]
	psi.description = dict.PSI[id]["description"]
	
	return psi

func use(caster, target, calling_entity):
	last_entity = calling_entity
	match type:
		"offensive":
			print("USE OFFENSE PSI")
		"recovery":
			if game_data.in_battle:
				pass
				#Battle Logic
			else:
				oob_recovery_psi(caster, target)
		"assist":
			print("USE ASSIST PSI")
		"other":
			print("USE OTHER PSI")

############################
## OUT OF BATTLE RECOVERY ##
############################

func oob_recovery_psi(caster, target):
	var c_name = caster.character_name
	var t_name = target.character_name
	target_to_heal = target
	active_caster = caster
	last_entity.switch_state("inactive")
	print("THIS PSI IS SUBTYPE: ", sub_type)
	if caster.pp >= cost:
		match sub_type:
			"Lifeup":
				print("%s is using a Lifeup PSI on %s. . ." % [caster.character_name, target.character_name])
				randomize()
				hp_rec = floor((rand_range(amount[1],amount[0])))
				pp_rec = 0
				pp_cost = cost
				var text_command
				if target.hp + hp_rec >= target.MAX_HP:
					text_command = "[sfx] [16] %s tried %s! [psi_deplete] [wait] [break] @ %s's HP maxed out! [psi_heal] [sfx] [1] [wait] [end]" % [c_name, psi_name, t_name]
				else:
					text_command = "[sfx] [16] %s tried %s! [psi_deplete] [wait] [break] @ %s gained %s HP! [psi_heal] [sfx] [1] [wait] [end]" % [c_name, psi_name, t_name, hp_rec]
				ui.text_box.ready_box(last_entity)
				ui.text_box.load_read(text_command, self)
			"Healing":
				print("%s is using a Healing PSI on %s. . ." % [caster.character_name, target.character_name])
			"PSI Magnet":
				print("%s is using a Magnet PSI on %s. . ." % [caster.character_name, target.character_name])
	else:
		var text_command = "[sfx] [16] %s tried %s! [wait] [break] @ But %s doesn't have enough PP [d] . [d] . [d] . [wait] [end]" % [c_name, psi_name, c_name]
		ui.text_box.ready_box(last_entity)
		ui.text_box.load_read(text_command, self)	

func psi_deplete():
	active_caster.pp -= pp_cost

func psi_heal():
	target_to_heal.hp += hp_rec
	target_to_heal.pp += pp_rec