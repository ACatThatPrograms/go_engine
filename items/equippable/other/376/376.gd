extends "res://items/item.gd"

var DATA = {
	"NAME": "Attack Ring", 
	"ID": 376,
	"TYPE": item.EQUIPPABLE,
	"EQUIP_TYPE": "OTHER",
	"EQUIP_OWNER": 0,
	"DESC": "A ring with a sword emblem. [wait] [break] @ Offense + 8 , Defense - 8 [wait] [end]",
	"OFFENSE": 8,
	"DEFENSE": -8,
	"EQUIPPED": false,
}

func _ready():
	pass