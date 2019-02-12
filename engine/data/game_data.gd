extends Node

var data_loaded = false
var save_available = false

# Signals

signal data_update_done
signal position_refresh

## Scene change animation constants
#Float from .00 - .99, this is the amount that rgb changes per frame from 0 -> 1, and vice versa
var fade_speed = .020

## Player Load Position Data

var update_position = false
var scene_play_open_sound = false
var player_load_position
var arrival_direction = ""

## Game Wide Data Points ##

var money = 20
var party_members = [0] # By character_id

## In battle flag

var in_battle = false

## Character Data ##
	## CHARACTER ID = 0 
var CHARACTER_DATA = [{
	"char_id" : 0,
	"name": "Ness", 
	"party_position": 0,
	"status": "Normal",
	"level": 1,
	"xp" : 0,
	"psi": [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33],
	"hp" : 15,
	"max_hp": 80,
	"pp" : 5,
	"max_pp": 40,
	"offense": 2,
	"defense": 2,
	"speed": 2,
	"guts" : 2,
	"vit" : 2,
	"iq" : 2,
	"luck": 2,
	"weapon": null,
	"body": null,
	"arms": null,
	"other": null,
	"inventory": [400, 402, 403, 400, 402, 300, 326, 376, 351],
	"equipment" : [],
	"skin": "res://player/assets/ness.png"
},
{	#CHARACTER ID = 1
	"char_id" : 1,
	"name": "Paula", 
	"party_position": 0,
	"status": "Normal",
	"level": 1,
	"xp" : 0,
	"psi": [0],
	"hp" : 30,
	"max_hp": 60,
	"pp" : 10,
	"max_pp": 80,
	"offense": 2,
	"defense": 2,
	"speed": 2,
	"guts" : 2,
	"vit" : 2,
	"iq" : 2,
	"luck": 2,
	"weapon": null,
	"body": null,
	"arms": null,
	"other": null,
	"inventory": [300, 400, 400],
	"equipment" : [],
	"skin": "res://player/assets/paula.png",
},
{	#CHARACTER ID = 2
	"char_id" : 2,
	"name": "Jeff", 
	"party_position": 0,
	"status": "Normal",
	"level": 1,
	"xp" : 0,
	"psi": [],
	"hp" : 30,
	"max_hp": 30,
	"pp" : 0,
	"max_pp": 0,
	"offense": 2,
	"defense": 2,
	"speed": 2,
	"guts" : 2,
	"vit" : 2,
	"iq" : 2,
	"luck": 2,
	"weapon": null,
	"body": null,
	"arms": null,
	"other": null,
	"inventory": [],
	"equipment" : [],
	"skin": "res://player/assets/jeff.png",
},
{	#CHARACTER ID = 3
	"char_id" : 3,
	"name": "Poo", 
	"party_position": 0,
	"status": "Normal",
	"level": 1,
	"xp" : 0,
	"psi": [],
	"hp" : 85,
	"max_hp": 85,
	"pp" : 110,
	"max_pp": 110,
	"offense": 2,
	"defense": 2,
	"speed": 2,
	"guts" : 2,
	"vit" : 2,
	"iq" : 2,
	"luck": 2,
	"weapon": null,
	"body": null,
	"arms": null,
	"other": null,
	"inventory": [],
	"equipment" : [],
	"skin": "res://player/assets/poo.png",
}
]

func scene_door_activated(door_calling, target_pos, arrival_dir, play_sound_on_open):
	connect("data_update_done", door_calling, "data_update_done")
	
	update_position = true
	player_load_position = target_pos
	arrival_direction = arrival_dir
	scene_play_open_sound = play_sound_on_open
	
	data_update()

func _ready():
	update_party_pos()
	load_data()

## Data manipulation

func update_party_pos():
	for x in CHARACTER_DATA:
		x["party_position"] = party_members.find(x["char_id"]) + 1
	emit_signal("position_refresh")

## Scene Transition Save Data

func data_update():
	for x in get_tree().get_nodes_in_group("party")[0].party_members:
		var extracted_dict = x.extract_data()
		CHARACTER_DATA[x.char_id] = extracted_dict
	emit_signal("data_update_done")

## Create Filesaves

func save_data():
	pass
func load_data():
	if save_available:
		pass
	else:
		pass