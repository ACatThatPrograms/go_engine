extends Node2D

const TYPE = "giftbox"

export (int) var giftbox_id
export (int) var item_id
var opened

func _init():
	pass

func _process(delta):
	if opened:
		$Sprite.frame = 1
	else:
		$Sprite.frame = 0

func _ready():
	load_state()
	if opened:
		$Sprite.frame = 1
	else:
		$Sprite.frame = 0

func load_state():
	opened = flags.giftbox_flags[giftbox_id]

func interact(interacting_entity):
	var ent = interacting_entity
	var member_with_space = get_tree().get_nodes_in_group("party")[0].check_inv_for_space()
	print(member_with_space.character_name, " has space.")
	var _item = item.fetch_item(item_id)
	if !opened:
		if member_with_space == null:
			ui.text_box().connect("close_box", self, "_close_box", [], 4)
			opened = true
			ui.text_box().load_read("%s found a %s! [wait] [break] @ But %s doesn't have space for it. [wait] [close_box] [end]" % [ent.character_name, _item.DATA["NAME"], ent.character_name], ent)
		else:
			ui.text_box().load_read("%s found a %s! [wait] [break] @ %s took it. [sfx] %s [wait] [end]" % [ent.character_name, _item.DATA["NAME"], member_with_space.character_name, _item.DATA["GET_SOUND"]], ent)
			member_with_space.inventory.append(_item.DATA["ID"])
			## Mark Opened
			opened = true
			flags.giftbox_flags[giftbox_id] = true
	else:
		ui.text_box().load_read("It is empty. [wait] [end]", ent)

func _close_box():
	opened = false