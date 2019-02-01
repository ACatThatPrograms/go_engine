extends "res://items/item.gd"

var DATA = {
	"NAME": "Brain Food Lunch", 
	"ID": 403,
	"TYPE": item.FOOD,
	"HP_REC": [275,310], #minmax values for hp & pp rec
	"PP_REC": [35,50],
	"DESC": "A meal fit for intelligence. [wait] [break] Recovers around 200 HP/PP. [wait] [end]"
}

func _ready():
	pass