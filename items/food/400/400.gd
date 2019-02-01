extends "res://items/item.gd"

var DATA = {
	"NAME": "Cookie", 
	"ID": 400,
	"TYPE": item.FOOD,
	"HP_REC": [4,7], #minmax values for hp & pp rec
	"PP_REC": [0,0],
	"DESC": "A delicious cookie. [wait] [break] Recovers around 6 HP. [wait] [end]",
	"GET_SOUND": "[10]"
}

func _ready():
	pass