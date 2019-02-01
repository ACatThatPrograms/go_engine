extends NinePatchRect

var state = "inactive"
var last_entity = null

var ready_for_input = false

var funds_udpated = false

func _ready():
	hide()
	pass

func _process(delta):
	match state:
		"active":
			update_funds()
			if ready_for_input:
				inputs()
				pass
			else:
				ready_for_input = true
		"inactive":
			if !funds_udpated:
				update_funds()
				funds_udpated = true
		"showing":
			update_funds()

#Funds editing
func update_funds():
	var money = game_data.money
	$container/amount.text = str(money)
	
func open(opening_entity):
	switch_state("active")
	if engine.DEBUG:
		print(opening_entity.character_name + " opened funds_box")
	opening_entity.switch_state("inactive")
	last_entity = opening_entity
	show()

func close():
	if engine.DEBUG:
		print(get_tree().get_nodes_in_group("party")[0].leader.character_name + " closed funds_box")
	hide()
	ready_for_input = false
	switch_state("inactive")
	get_tree().get_nodes_in_group("party")[0].leader.switch_state("active")

func switch_state(newState):
	state = newState

#Inputs
func inputs():
	if Input.is_action_just_pressed("snes_b"):
		audio.get_node("sfx").play_sound(dict.sfx_id["[5]"])
		get_parent().close_funds()

#Signals

func _goods_menu_opened():
	switch_state("showing")
	show()

func _player_menu_closed():
	switch_state("inactive")
	ready_for_input = false
	hide()
