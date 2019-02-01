extends "res://ui/components/game_menus/menu_base.gd"

var last_entity # Last entity to open screen ( Not Character )

func _ready():
	state = "inactive"

func _process(delta):
	match state:
		"active":
			arrow_anims()
			if ready_for_input:
				input()
			else:
				ready_for_input = true
		"inactive":
			pass

###########################
##         INPUT         ##
###########################

func input():
	if Input.is_action_just_pressed("snes_b"):
		close()

###########################
## OPEN / CLOSE COMMANDS ##
###########################

func open(opening_entity):
	show()
	opening_entity.switch_state("inactive")
	last_entity = opening_entity
	switch_state("active")

func close():
	hide()
	last_entity.switch_state("active")
	switch_state("inactive")
	ready_for_input = false

###########################
##  ANIMATION HANDLERS   ##
###########################

func arrow_anims():
	if $anim.is_playing():
		pass
	else:
		$anim.play("arrow_flash")



###########################
##### STATE SWITCHING #####
###########################

func switch_state(newState):
	state = newState