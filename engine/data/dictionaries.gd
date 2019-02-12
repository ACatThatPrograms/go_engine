extends Node

####################
##  SFX ID TABLE  ##
####################

var sfx_id = {
	"[0]" : "res://sound/fx/eat.wav",				# Eating sound
	"[1]" : "res://sound/fx/heal 1.wav",			# Heal HP Up (Food, PSI)
	"[2]" : "res://sound/fx/wound.wav",				# Player Critical SFX
	"[3]" : "res://sound/fx/die.wav",				# Knockout SFX
	"[4]" : "res://sound/fx/cursverti.wav",			# Menu up/down beep and enter beep
	"[5]" : "res://sound/fx/curshoriz.wav",			# Menu sideways beep & exit beep
	"[6]" : "res://sound/fx/click.wav",				# Menu Click
	"[7]" : "res://sound/fx/window.wav", 			# Window open & close
	"[8]" : "res://sound/fx/dooropen1.wav",			# Door open
	"[9]" : "res://sound/fx/doorclose.wav",			# Door close
	"[10]" : "res://sound/fx/itemget1.wav" ,		# Item get default
	"[11]" : "res://sound/fx/itemget2.wav",			# Item get special
	"[12]" : "res://sound/fx/steps.wav",			# Walking down/up steps
	"[13]" : "res://sound/fx/bird.wav",				# Bird Chirp
	"[14]" : "res://sound/fx/yell.wav",				# Yell
	"[15]" : "res://sound/fx/eb_newchar.wav",		# Party Join!
	"[16]" : "res://sound/fx/psi.wav",				# PSI Use 1
	"[17]" : "res://sound/fx/equip.wav", # Equip
	"[18]" : "", # Unequip
}

####################
## MUSIC ID TABLE ##
####################

var music_id = {
	"[0]" : "res://sound/music/home.ogg",			# Home Sweet Home
	"[1]" : "res://sound/music/good_morning.ogg",	# Good Morning
	"[2]" : "res://sound/music/onett.ogg"			# Onett
}

####################
## PSI DATA TABLE ##
####################

var PSI = {
	0 : {
		"name": "Lifeup A",
		"type" : "recovery",
		"sub_type": "Lifeup",
		"level": "alpha",
		"cost": 5,
		"target" : "ally_single",
		"amount": [80,120],
		"description" : "Restores 100 HP to a single ally"
	},
	1 : {
		"name": "Lifeup B",
		"type" : "recovery",
		"sub_type": "Lifeup",
		"level": "beta",
		"cost": 8,
		"target" : "ally_single",
		"amount": [265,345],
		"description" : "Restores 300 HP to a single ally"
	},
	2 : {
		"name": "Lifeup C",
		"type" : "recovery",
		"sub_type": "Lifeup",
		"level": "gamma",
		"cost": 14,
		"target" : "ally_single",
		"amount": [99999,99999],
		"description" : "Restores All HP to a single ally"
	},
	3 : {
		"name": "Lifeup D",
		"type" : "recovery",
		"sub_type": "Lifeup",
		"level": "omega",
		"cost": 42,
		"target" : "ally_all",
		"amount": [350,450],
		"description" : "Restores 400 HP to all allies"
	},
	4 : {
		"name": "Healing A",
		"type" : "recovery",
		"sub_type": "Healing",
		"level": "alpha",
		"cost": 6,
		"target" : "ally_single",
		"amount": [0,0],
		"description" : "Heal minor injuries and illnesses"
	},
	5 : {
		"name": "Healing B",
		"type" : "recovery",
		"sub_type": "Healing",
		"level": "beta",
		"cost": 14,
		"target" : "ally_single",
		"amount": [0,0],
		"description" : "Heal severe injuries and illnesses"
	},
	6 : {
		"name": "Healing C",
		"type" : "recovery",
		"sub_type": "Healing",
		"level": "gamma",
		"cost": 18,
		"target" : "ally_single",
		"amount": [0,0],
		"description" : "Heal fatal injuries and illnesses"
	},
	7 : {
		"name": "Healing D",
		"type" : "recovery",
		"sub_type": "Healing",
		"level": "omega",
		"cost": 38,
		"target" : "ally_single",
		"amount": [0,0],
		"description" : "Completely restore status\nAdditionally restores all health"
	},
	8 : {
		"name": "PSI Magnet A",
		"type" : "recovery",
		"sub_type": "PSI Magnet",
		"level": "alpha",
		"cost": 0,
		"target" : "enemy_single",
		"amount": [0,0],
		"description" : "Syphon PP from an enemy"
	},
	9 : {
		"name": "PSI Magnet D",
		"type" : "recovery",
		"sub_type": "PSI Magnet",
		"level": "omega",
		"cost": 0,
		"target" : "enemy_all",
		"amount": [0,0],
		"description" : "Siphon PP from multiple enemies"
	},
	10 : {
		"name": "PSI Rockin A",
		"type" : "offensive",
		"sub_type": "PSI Rockin",
		"level": "alpha",
		"cost": 10,
		"target" : "enemy_all",
		"amount": [40,60],
		"description" : "A deadly psionic attack\nDeals around 50 HP"
	},
	11 : {
		"name": "PSI Rockin B",
		"type" : "offensive",
		"sub_type": "PSI Rockin",
		"level": "beta",
		"cost": 18,
		"target" : "enemy_all",
		"amount": [160,180],
		"description" : "A deadly psionic attack\nDeals around 170 HP"
	},
	12 : {
		"name": "PSI Rockin C",
		"type" : "offensive",
		"sub_type": "PSI Rockin",
		"level": "gamma",
		"cost": 70,
		"target" : "enemy_all",
		"amount": [300,500],
		"description" : "A deadly psionic attack\nDeals around 400HP"
	},
	13 : {
		"name": "PSI Rockin D",
		"type" : "offensive",
		"sub_type": "PSI Rockin",
		"level": "omega",
		"cost": 144,
		"target" : "enemy_all",
		"amount": [700,900],
		"description" : "A deadly psionic attack\nDeals around 800HP"
	},
	14 : {
		"name": "PSI Flash A",
		"type" : "offensive",
		"sub_type": "PSI Flash",
		"level": "alpha",
		"cost": 10,
		"target" : "enemy_all",
		"amount": [0],
		"description" : "Generate a bright psionic flash\nInflict minor status effects"
	},
	15 : {
		"name": "PSI Flash B",
		"type" : "offensive",
		"sub_type": "PSI Flash",
		"level": "beta",
		"cost": 30,
		"target" : "enemy_all",
		"amount": [0],
		"description" : "Generate a bright psionic flash\nInflict greater status effects"
	},
	16 :  {
		"name": "PSI Flash C",
		"type" : "offensive",
		"sub_type": "PSI Flash",
		"level": "gamma",
		"cost": 50,
		"target" : "enemy_all",
		"amount": [0],
		"description" : "Generate a bright psionic flash\nInflict major status effects"
	},
	17 :  {
		"name": "PSI Flash D",
		"type" : "offensive",
		"sub_type": "PSI Flash",
		"level": "omega",
		"cost": 90,
		"target" : "enemy_all",
		"amount": [0],
		"description" : "Generate a bright psionic flash\nInflict major status effects\nMay cause unconsciousness"
	},
	18 :  {
		"name": "PSI Teleport A",
		"type" : "other",
		"sub_type": "Teleport",
		"level": "alpha",
		"cost": 2,
		"target" : "ally_all",
		"amount": [0],
		"description" : "A transportation technique\nTakes a lot of room"
	},
	19 :  {
		"name": "PSI Teleport B",
		"type" : "other",
		"sub_type": "Teleport",
		"level": "beta",
		"cost": 8,
		"target" : "ally_all",
		"amount": [0],
		"description" : "A transportation technique\nTakes less room"
	},
	20 :  {
		"name": "PSI Teleport D",
		"type" : "other",
		"sub_type": "Teleport",
		"level": "omega",
		"cost": 18,
		"target" : "ally_all",
		"amount": [0],
		"description" : "A transportation technique\nTakes almost no room"
	},
	21 :  {
		"name": "Offense Down A",
		"type" : "assist",
		"sub_type": "Offense Down",
		"level": "alpha",
		"cost": 18,
		"target" : "enemy_single",
		"amount": [8,16],
		"description" : "Reduce a single enemy's offense"
	},
	22 :  {
		"name": "PSI Thunder A",
		"type" : "offensive",
		"sub_type": "PSI Thunder",
		"level": "alpha",
		"cost": 4,
		"target" : "enemy_single",
		"amount": [80,120],
		"description" : "Generate 1  bolt of lightning\nDeals 100 damage each\nMight miss"
	},
	23 :  {
		"name": "PSI Thunder B",
		"type" : "offensive",
		"sub_type": "PSI Thunder",
		"level": "beta",
		"cost": 9,
		"target" : "enemy_single",
		"amount": [80,120],
		"description" : "Generate 2  bolts of lightning\nDeals 100 damage each\nMight miss"
	},
	24 :  {
		"name": "PSI Thunder C",
		"type" : "offensive",
		"sub_type": "PSI Thunder",
		"level": "gamma",
		"cost": 21,
		"target" : "enemy_single",
		"amount": [80,120],
		"description" : "Generate 3  bolts of lightning\nDeals 100 damage each\nMight miss"
	},
	25 :  {
		"name": "PSI Thunder D",
		"type" : "offensive",
		"sub_type": "PSI Thunder",
		"level": "omega",
		"cost": 29,
		"target" : "enemy_single",
		"amount": [80,120],
		"description" : "Generate 4  bolts of lightning\nDeals 100 damage each\nMight miss"
	},
	26 :  {
		"name": "PSI Freeze A",
		"type" : "offensive",
		"sub_type": "PSI Freeze",
		"level": "alpha",
		"cost": 6,
		"target" : "enemy_single",
		"amount": [70,130],
		"description" : "Generate an ice cold freeze\nDeals 80 damage\nMay solidify target"
	},
	27 :  {
		"name": "PSI Freeze B",
		"type" : "offensive",
		"sub_type": "PSI Freeze",
		"level": "beta",
		"cost": 13,
		"target" : "enemy_single",
		"amount": [120,180],
		"description" : "Generate an ice cold freeze\nDeals 150 damage\nMay solidify target"
	},
	28 :  {
		"name": "PSI Freeze C",
		"type" : "offensive",
		"sub_type": "PSI Freeze",
		"level": "gamma",
		"cost": 23,
		"target" : "enemy_single",
		"amount": [280,410],
		"description" : "Generate an ice cold freeze\nDeals 290 damage\nMay solidify target"
	},
	29 :  {
		"name": "PSI Freeze D",
		"type" : "offensive",
		"sub_type": "PSI Freeze",
		"level": "omega",
		"cost": 35,
		"target" : "enemy_single",
		"amount": [490,550],
		"description" : "Generate an ice cold freeze\nDeals 520 damage\nMay solidify target"
	},
	30 :  {
		"name": "PSI Fire A",
		"type" : "offensive",
		"sub_type": "PSI Fire",
		"level": "alpha",
		"cost": 7,
		"target" : "enemy_row",
		"amount": [40,80],
		"description" : "Generate an stream of fire\nDeals 60 damage"
	},
	31 :  {
		"name": "PSI Fire B",
		"type" : "offensive",
		"sub_type": "PSI Fire",
		"level": "beta",
		"cost": 19,
		"target" : "enemy_row",
		"amount": [90,160],
		"description" : "Generate an stream of fire\nDeals 130 damage"
	},
	32 :  {
		"name": "PSI Fire C",
		"type" : "offensive",
		"sub_type": "PSI Fire",
		"level": "gamma",
		"cost": 27,
		"target" : "enemy_row",
		"amount": [210,260],
		"description" : "Generate an stream of fire\nDeals 235 damage"
	},
	33 :  {
		"name": "PSI Fire D",
		"type" : "offensive",
		"sub_type": "PSI Fire",
		"level": "omega",
		"cost": 42,
		"target" : "enemy_row",
		"amount": [280,360],
		"description" : "Generate an stream of fire\nDeals 330 damage"
	},
}

#############################
##  CHAR_WIDTH Dictionary  ##
#############################

var char_size = {
	" " : 3,
	"a" : 5,
	"b" : 4,
	"c" : 4,
	"d" : 4,
	"e" : 4,
	"f" : 3,
	"g" : 4,
	"h" : 4,
	"i" : 1,
	"j" : 2,
	"k" : 4,
	"l" : 1,
	"m" : 7,
	"n" : 4,
	"o" : 4,
	"p" : 4,
	"q" : 4,
	"r" : 3,
	"s" : 4,
	"t" : 3,
	"u" : 4,
	"v" : 5,
	"w" : 7,
	"x" : 4,
	"y" : 4,
	"z" : 4,
	"A" : 6, 
	"B" : 5,
	"C" : 5,
	"D" : 5,
	"E" : 4,
	"F" : 4,
	"G" : 5,
	"H" : 5,
	"I" : 1,
	"J" : 4,
	"K" : 5,
	"L" : 5,
	"M" : 7,
	"N" : 5,
	"O" : 6,
	"P" : 5,
	"Q" : 6,
	"R" : 5,
	"S" : 5,
	"T" : 5,
	"U" : 6,
	"V" : 6,
	"W" : 7,
	"X" : 5,
	"Y" : 5,
	"Z" : 5,
	"." : 1,
	"," : 2,
	"!" : 1,
	"$" : 5,
	"*" : 3,
	"(" : 3,
	")" : 3,	
	"?" : 4,
	"'" : 1,
	"0" : 4,
	"1" : 2,
	"2" : 4,
	"3" : 4,
	"4" : 5,
	"5" : 4,
	"6" : 4,
	"7" : 4,
	"8" : 4,
	"9" : 4,
	"/" : 5,
	"#" : 5,
	"&" : 5,
	'"' : 3,
	"-" : 5,
	"+" : 5,
	}