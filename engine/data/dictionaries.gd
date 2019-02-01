extends Node

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
	}

var sfx_id = {
	"[0]" : "res://sound/fx/eat.wav",				# Eating sound
	"[1]" : "res://sound/fx/heal 1.wav",			# Heal (Food)
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
	"[15]" : "res://sound/fx/eb_newchar.wav"		# Party Join!
}

var music_id = {
	"[0]" : "res://sound/music/home.ogg",			# Home Sweet Home
	"[1]" : "res://sound/music/good_morning.ogg",	# Good Morning
	"[2]" : "res://sound/music/onett.ogg"			# Onett
}