extends "res://items/item.gd"

var DATA = {
	"NAME": "PSI Caramel", 
	"ID": 402,
	"TYPE": item.FOOD,
	"HP_REC": [0,0], #minmax values for hp & pp rec
	"PP_REC": [17,23],
	"DESC": "A homemade caramel. [wait] [break] Recovers around 20 PP. [wait] [end]"
}

func _ready():
	pass