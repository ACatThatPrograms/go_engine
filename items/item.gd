extends Node

## Enum Constants for Inventory Management

enum TYPE{
	BATTLE, 		#   0 - 99
	BROKEN, 		# 100 - 199
	CAPSULE, 		# 200 - 299
	EQUIPPABLE,		# 300 - 399
	FOOD,			# 400 - 499
	INGREDIENTS,	# 500 - 599
	KEY,			# 600 - 699
	NO_EFFECT,		# 700 - 799
	REMEDY,			# 800 - 899
	REUSABLE		# 900 - 999
}

enum EQUIP_TYPE{
	WEAPON, 		# 300 - 325
	BODY,			# 326 - 350
	ARMS,			# 351 - 375
	OTHER			# 376 - 499
}

enum EQUIP_USER{
	CHARACTER_1,
	CHARACTER_2,
	CHARACTER_3,
	CHARACTER_4,
	ALL
}

## Textbox

var text_box = null

## Signals

signal command_loaded

## Food specific

var hp_to_rec = 0
var pp_to_rec = 0
var heal_target = "Null"

# Text_box related

var command_to_send = null

## All available item IDs ##
## Item IDs match EB's Item ID System ##

var ITEM_ID = {
	## EQUIPPABLES - WEAPONS
	300:"res://items/equippable/weapons/300/300.tscn", 	# Cracked Bat
	## EQUIPPABLED - BODY
	326:"res://items/equippable/body/326/326.tscn", 	# Travel Charm
	## EQUIPPABLED - ARMS
	351:"res://items/equippable/arms/351/351.tscn", # Copper Bracelet
	## EQUIPPABLED - OTHER
	376:"res://items/equippable/other/376/376.tscn", # Attack Ring
	## FOOD
	400:"res://items/food/400/400.tscn", # Cookie
	401:"res://items/food/401/401.tscn", # Hamburger
	402:"res://items/food/402/402.tscn", # PSI Caramel
	403:"res://items/food/403/403.tscn", # Brain food lunch
	}

func _ready():
	connect("command_loaded", self, "send_command_to_textbox")
	if !get_tree().get_nodes_in_group("ui"):
		pass
	else:
		text_box = get_tree().get_nodes_in_group("ui")[0].get_node("text_box")

func _process(delta):
	pass

## Used for loading items to populate inventory,
## Generate items from giftboxes, loot, etc
func fetch_item(item_ID):
	var newItem = load(ITEM_ID[item_ID]).instance()
	return newItem
	pass

func use(item, user, target, calling_entity): # Calling entity is menu or object that needs to regain state
	match item.DATA["TYPE"]:
		BATTLE:
			print("Battle")
		BROKEN:
			print("Broken")		
		CAPSULE:
			print("Capsule")
		EQUIPPABLE:
			use_equippable(item, user, target, calling_entity)
		FOOD:
			use_food(item, user, target, calling_entity)
		INGREDIENTS:
			print("Ingredient")
		KEY:
			print("Key")
		NO_EFFECT:
			print("No_Effect")
		REMEDY:
			print("Remedy")
		REUSABLE:
			print("Reusable")

## Item Use Functions

func use_food(item, user, target, calling_entity):
	print("From item :" , calling_entity.name)
	calling_entity.switch_state("inactive")
	
	if game_data.party_members.size() == 1:
		heal_target = target
		var hp_rec = 0
		var pp_rec = 0
		randomize()
		
		if item.DATA["HP_REC"][0] != 0:
			hp_rec = floor(rand_range(item.DATA["HP_REC"][0],item.DATA["HP_REC"][1]))
			hp_to_rec = hp_rec
		
		if item.DATA["PP_REC"][0] != 0:
			pp_rec = floor(rand_range(item.DATA["PP_REC"][0],item.DATA["PP_REC"][1]))
			pp_to_rec = pp_rec
		
		## HP & PP
		if pp_rec != 0 && hp_rec != 0:
			
			if pp_rec + target.pp >= target.MAX_PP &&  hp_rec + target.hp >= target.MAX_HP:
				command_to_send = "%s ate the %s. [sfx] [0] [wait] [break] [item_heal] %s's HP and PP maxed out! [sfx] [1] [wait] [end]" % [user.character_name, item.DATA["NAME"], user.character_name]
				emit_signal("command_loaded")
			elif pp_rec + target.pp >= target.MAX_PP && hp_rec + target.hp < target.MAX_HP:
				command_to_send = "%s ate the %s. [sfx] [0] [wait] [break] [item_heal] %s recovered %s HP [break] %s's PP maxed out! [sfx] [1] [wait] [end]" % [user.character_name, item.DATA["NAME"], user.character_name, hp_rec, user.character_name]
				emit_signal("command_loaded")
			elif hp_rec + target.hp >= target.MAX_HP && pp_rec + target.pp < target.MAX_PP:
				command_to_send = "%s ate the %s. [sfx] [0] [wait] [break] [item_heal] %s HP maxed out! [break] %s recovered %s PP. [sfx] [1] [wait] [end]" % [user.character_name, item.DATA["NAME"], user.character_name, user.character_name, pp_rec]
				emit_signal("command_loaded")
			else:
				command_to_send = "%s ate the %s. [sfx] [0] [wait] [break] [item_heal] %s recovered %s HP and %s PP. [sfx] [1] [wait] [end]" % [user.character_name, item.DATA["NAME"], user.character_name, hp_rec, pp_rec]
				emit_signal("command_loaded")

		## JUST PP
		elif hp_rec == 0 && pp_rec != 0:
			if pp_rec + target.pp >= target.MAX_PP:
				command_to_send = "%s ate the %s. [sfx] [0] [wait] [break] [item_heal] %s's PP maxed out! [sfx] [1] [wait] [end]" % [user.character_name, item.DATA["NAME"], user.character_name]
				emit_signal("command_loaded")
			else:
				command_to_send = "%s ate the %s. [sfx] [0] [wait] [break] [item_heal] %s recovered %s PP. [sfx] [1] [wait] [end]" % [user.character_name, item.DATA["NAME"], user.character_name, pp_rec]
				emit_signal("command_loaded")

		## JUST HP
		elif hp_rec != 0:
			if hp_rec + target.hp >= target.MAX_HP:
				command_to_send = "%s ate the %s. [sfx] [0] [wait] [break] [item_heal] %s's HP maxed out! [sfx] [1] [wait] [end]" % [user.character_name, item.DATA["NAME"], user.character_name]
				emit_signal("command_loaded")
			else:
				command_to_send = "%s ate the %s. [sfx] [0] [wait] [break] [item_heal] %s recovered %s HP. [sfx] [1] [wait] [end]" % [user.character_name, item.DATA["NAME"], user.character_name, hp_rec]
				emit_signal("command_loaded")
		
		text_box.connect("text_done", text_box, "_text_done_close_caller", [calling_entity], 4) # 4 = one shot
	
	else:
		heal_target = target
		var hp_rec = 0
		var pp_rec = 0
		randomize()
		
		if item.DATA["HP_REC"][0] != 0:
			hp_rec = floor(rand_range(item.DATA["HP_REC"][0],item.DATA["HP_REC"][1]))
			hp_to_rec = hp_rec
		
		if item.DATA["PP_REC"][0] != 0:
			pp_rec = floor(rand_range(item.DATA["PP_REC"][0],item.DATA["PP_REC"][1]))
			pp_to_rec = pp_rec
		
		## HP & PP
		if pp_rec != 0 && hp_rec != 0:
			## BOTH MAX
			if pp_rec + target.pp >= target.MAX_PP &&  hp_rec + target.hp >= target.MAX_HP:
				command_to_send = "%s took the %s out and [wait] [break] @ %s ate it. [sfx] [0] [wait] [break] @ [item_heal] %s's HP & PP Maxed out! [sfx] [1] [wait] [end]" % [user.character_name, item.DATA["NAME"], target.character_name, target.character_name]
				emit_signal("command_loaded")
			## HP REC, PP MAX
			elif pp_rec + target.pp >= target.MAX_PP && hp_rec + target.hp < target.MAX_HP:
				command_to_send = "%s took the %s out and [wait] [break] @ %s ate it. [sfx] [0] [wait] [break] @ [item_heal] %s Recovered %s HP & PP Maxed out! [sfx] [1] [wait] [end]" % [user.character_name, item.DATA["NAME"], target.character_name, target.character_name, hp_rec]
				emit_signal("command_loaded")
			## HP MAX, PP REC
			elif hp_rec + target.hp >= target.MAX_HP && pp_rec + target.pp < target.MAX_PP:
				command_to_send = "%s took the %s out and [wait] [break] @ %s ate it. [sfx] [0] [wait] [break] @ [item_heal] %s HP Maxed out & recovered %s PP! [sfx] [1] [wait] [end]" % [user.character_name, item.DATA["NAME"], target.character_name, target.character_name, pp_rec]
				emit_signal("command_loaded")
			## Both Rec, No Max
			else:
				command_to_send = "%s took the %s out and [wait] [break] @ %s ate it. [sfx] [0] [wait] [break] @ [item_heal] %s recovered %s HP and %s PP! [sfx] [1] [wait] [end]" % [user.character_name, item.DATA["NAME"], target.character_name, target.character_name, hp_rec, pp_rec]
				emit_signal("command_loaded")

		## JUST PP
		elif hp_rec == 0 && pp_rec != 0:
			if pp_rec + target.pp >= target.MAX_PP:
				command_to_send = "%s took the %s out and [wait] [break] @ %s ate it. [sfx] [0] [wait] [break] @ [item_heal] %s's PP Maxed out! [sfx] [1] [wait] [end]" % [user.character_name, item.DATA["NAME"], target.character_name, target.character_name]
				emit_signal("command_loaded")
			else:
				command_to_send = "%s took the %s out and [wait] [break] @ %s ate it. [sfx] [0] [wait] [break] @ [item_heal] %s recovered [break] %s PP! [sfx] [1] [wait] [end]" % [user.character_name, item.DATA["NAME"], target.character_name, target.character_name, pp_rec]
				emit_signal("command_loaded")

		## JUST HP
		elif hp_rec != 0:
			if hp_rec + target.hp >= target.MAX_HP:
				command_to_send = "%s took the %s out and [wait] [break] @ %s ate it. [sfx] [0] [wait] [break] @ [item_heal] %s's HP Maxed out! [sfx] [1] [wait] [end]" % [user.character_name, item.DATA["NAME"], target.character_name, target.character_name]
				emit_signal("command_loaded")
			else:
				command_to_send = "%s took the %s out and [wait] [break] @ %s ate it. [sfx] [0] [wait] [break] @ [item_heal] %s recovered [break] %s HP! [sfx] [1] [wait] [end]" % [user.character_name, item.DATA["NAME"], target.character_name, target.character_name, hp_rec]
				emit_signal("command_loaded")
		
		text_box.connect("text_done", text_box, "_text_done_close_group", [[calling_entity, calling_entity.get_parent().get_node("goods_sub_menu")]], 4) # 4 = one shot

func item_heal():
	get_tree().get_nodes_in_group("ui")[0].get_node("goods_menu").remove_item(self)
	heal_target.hp += hp_to_rec
	heal_target.pp += pp_to_rec

func use_equippable(item, user, target, calling_entity):
	calling_entity.switch_state("inactive")
	
	if !item.DATA["EQUIPPED"]:
		if target.char_id == item.DATA["EQUIP_OWNER"] || item.DATA["EQUIP_OWNER"] == item.ALL:
			target.equip_item_from_goods(item)
			command_to_send = "[sfx] [17] %s equipped the %s. [wait] [break] [end]" % [target.character_name, item.DATA["NAME"]]
			emit_signal("command_loaded")
		else:
			command_to_send = "%s can't equip the %s. [wait] [break] [end]" % [target.character_name, item.DATA["NAME"]]
			emit_signal("command_loaded")
	else:
		target.unequip_item_from_goods(item)
		command_to_send = "[sfx] [5] %s unequipped the %s. [wait] [break] [end]" % [target.character_name, item.DATA["NAME"]]
		emit_signal("command_loaded")
	
	text_box.connect("text_done", text_box, "_text_done_close_group", [[calling_entity]], 4) # 4 = one shot

## Textbox Command Load - Called automatically after command_loaded signal

func send_command_to_textbox():
	text_box.load_command(command_to_send)
	text_box.read_command(self, true)