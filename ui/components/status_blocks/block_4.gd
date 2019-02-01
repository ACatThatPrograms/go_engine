extends "res://ui/components/status_blocks/block_base.gd"

func _init():
	init("null",1,1)
	block_name = "Block_4"

func _ready():
	pass

func _process(delta):
	if get_parent().DEBUG_STATUS_BOX:
		debug_inputs()
	else:
		pass