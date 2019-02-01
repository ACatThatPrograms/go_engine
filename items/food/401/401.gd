extends "res://items/item.gd"

var DATA = {
	"NAME": "Hamburger", 
	"ID": 401,
	"TYPE": item.FOOD,
	"HP_REC": [12,17], #minmax values for hp & pp rec
	"PP_REC": [0,0],
	"DESC": "A fresh juicy hamburger. [wait] [break] Recovers around 15 HP. [wait] [end]"
}

func _ready():
	pass