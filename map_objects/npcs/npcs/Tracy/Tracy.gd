extends "res://map_objects/npcs/npc.gd"

func _ready():
	pass

func _process(delta):
	check_command()

func check_command():
## With override script = true, place any textchanging
# flags here in order of gameplay from bottom to top
# Set all to set default etxt, then set special char texts below
	
	if flags.giftbox_flags[0] == true:
		set_all("Wow, I can't believe you guys. [wait] [break] @ You could have just asked. [wait] [end]")
		set_id(0, "I thought you were better than that. [wait] [end]")
	elif flags.flags[0]:
		set_id(0, "Your friends are downstairs waiting you know. [wait] [end]")