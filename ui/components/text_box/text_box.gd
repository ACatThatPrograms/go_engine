extends "res://ui/components/text_box/text_parse.gd"

signal text_done

func _init():
	if ISOLATE_AND_DEBUG_TEXT_BOX:
		should_hide = false
	else:
		should_hide = true

func _ready():
	print(get_tree().get_nodes_in_group("ui"))
	$text.clear()
	if ISOLATE_AND_DEBUG_TEXT_BOX:	
		state = "active"
	else:
		state = "inactive"

func _process(delta):
	match sub_state:
		"waiting":
			wait_arrow()
		"parsing":
			if $arrow.is_visible():
				$arrow.hide()
		"inactive":
			if $arrow.is_visible():
				$arrow.hide()

## Wait Arrow Animation

func wait_arrow():
	if !$arrow.is_visible():
		$arrow.show()
	
	if arrow_blink_rate < arrow_blink_rate_init:
		arrow_blink_rate += 1
	else:
		if $arrow.frame == 0:
			$arrow.frame = 1
		else:
			$arrow.frame = 0
		arrow_blink_rate = 0

## Ready text box, call before loading and reading

func ready_box(calling_ent): ## Old ui.textbox().connects can be refactored to this
	if !is_connected("text_done", self, "_text_done"):
		connect("text_done", self, "_text_done", [calling_ent], 4)

# Connect chocie

func connect_choice(calling_ent):
	connect("choice_yes", calling_ent, "_choice_yes")
	connect("choice_no", calling_ent, "_choice_no")

## SIGNALS

func _text_done(who_called):
	if who_called.get("character_name") && TEXT_DEBUG:
		print("Text ended by: ", who_called.character_name)
	elif TEXT_DEBUG:
		print(who_called.name)
	hide()
	switch_state("inactive")
	if TEXT_DEBUG:
		pass
		#print("Text initiated by %s has ended." % who_called.name)
	if who_called.get("state"):
		who_called.switch_state("active")

func _text_done_close_caller(who_called): ## Closes last called entity on text end
	hide()
	switch_state("inactive")
	who_called.close()

func _text_done_close_group(group_array):
	hide()
	switch_state("inactive")
	for x in group_array:
		x.hide()
		x.switch_state("inactive")
		x.close()