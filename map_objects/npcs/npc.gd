extends "res://engine/entity.gd"

export(String) var movement_type = "wander"
export(String, MULTILINE) var speak_command
export(String, MULTILINE) var char_0_speak
export(String, MULTILINE) var char_1_speak
export(String, MULTILINE) var char_2_speak
export(String, MULTILINE) var char_3_speak

var default_speak
var active_entity # Person speaking with

## Speech flags

var speaking = false
var state

## Movement Flags

var move_dirs = ["still","up","down","left","right"]
var m_dir = 0
var frames_to_hold_anim = 100
var anim_wait = false # Flag to pause between direction changes
var still_frame_swap = 25
var still_frame_default = 25

var walk_to_pos

func _ready():
	state = "active"
	TYPE = "NPC"
	MAP_SPEED = 20
	default_speak = speak_command

func _process(delta):
	movement()
	debug_input()
	pass

func movement():
	match state:
		"active":
			if speaking:
				pass
			else:
				match movement_type:
					"wander":
						wandering()
					"still":
						still()
		"inactive":
			pass

func switch_state(newState):
	state = newState

################
## Move Types ##
################

func wandering():
	if frames_to_hold_anim > 0:
		if m_dir == 0:
			pass
		if m_dir == 1 && !test_move(transform, dir._up):
			move_and_slide(dir._up * MAP_SPEED, Vector2(0,0))
		if m_dir == 2  && !test_move(transform, dir._down):
			move_and_slide(dir._down * MAP_SPEED, Vector2(0,0))
		if m_dir == 3  && !test_move(transform, dir._right):
			move_and_slide(dir._right * MAP_SPEED, Vector2(0,0))
		if m_dir == 4  && !test_move(transform, dir._left):
			move_and_slide(dir._left * MAP_SPEED, Vector2(0,0))
		
		frames_to_hold_anim -= 1
		
	else:
		if anim_wait:
			m_dir = 0
			anim_wait = false
		else:
			randomize()
			m_dir = randi()%5
			anim_wait = true
			
		frames_to_hold_anim = floor(rand_range(50, 100))
		print(frames_to_hold_anim)

func still():
	if still_frame_swap > 0:
		still_frame_swap -= 1
	else:
		$Sprite.flip_h = !$Sprite.flip_h
		still_frame_swap = still_frame_default

func talk_to(init_entity): # Turn sprite and lock when spoken to
	speaking = true
	active_entity = init_entity
	var dir_to_turn = (init_entity.position - position).normalized()
	if dir_to_turn.x > .8:
		dir_to_turn = dir._right
	elif dir_to_turn.x < -.8:
		dir_to_turn = dir._left
	elif dir_to_turn.y > .8:
		dir_to_turn = dir._down
	elif dir_to_turn.y < -.8:
		dir_to_turn = dir._up
	
	match init_entity.char_id:
		0:
			speak_command = char_0_speak
		1:
			speak_command = char_1_speak
		2:
			speak_command = char_2_speak
		3:
			speak_command = char_3_speak
		_:
			speak_command = default_speak
	
	turn_sprite(dir_to_turn)
	connect_text_box()
	ui.text_box().load_read(speak_command, init_entity)

func _done_speaking():
	speaking = false

func connect_text_box():
	if !ui.text_box().is_connected("text_done", self, "_done_speaking"):
		ui.text_box().connect("text_done", self, "_done_speaking", [], 4)

###################
## Speech Update ##
###################

func set_all(command):
	char_0_speak = command
	char_1_speak = command
	char_2_speak = command
	char_3_speak = command
	default_speak = command

func set_id(id, command):
	match id:
		"d":
			default_speak = command			
		0:
			char_0_speak = command
		1:
			char_1_speak = command
		2:
			char_2_speak = command
		3:
			char_3_speak = command

################
## ANIMATION  ##
################

func turn_sprite(direction):
	match direction:
		dir._right:
			$Sprite.frame = 2
			$Sprite.flip_h = true
		dir._left:
			$Sprite.frame = 2
			$Sprite.flip_h = false
		dir._up:
			$Sprite.frame = 1
		dir._down:
			$Sprite.frame = 0
			$Sprite.flip_h = true

func walk_to(target):
	var absolute = (target-position)
	var distance
	if absolute.x > absolute.y:
		target = Vector2(target.x, position.y)
		distance = absolute.x
	else:
		target = Vector2(position.x, target.y)
		distance = absolute.y
	$tween.interpolate_property(self, "position", position, target, distance / 10, $tween.TRANS_LINEAR, $tween.EASE_IN_OUT)
	$tween.start()

#################
## DEBUG INPUT ##
#################

func debug_input():
	if Input.is_action_pressed("debug_secondary_up") && !test_move(transform, dir._up):
		move_and_slide(dir._up * MAP_SPEED, Vector2(0,0))
	if Input.is_action_pressed("debug_secondary_down") && !test_move(transform, dir._down):
		move_and_slide(dir._down * MAP_SPEED, Vector2(0,0))
	if Input.is_action_pressed("debug_secondary_right") && !test_move(transform, dir._right):
		move_and_slide(dir._right * MAP_SPEED, Vector2(0,0))
	if Input.is_action_pressed("debug_secondary_left") && !test_move(transform, dir._left):
		move_and_slide(dir._left * MAP_SPEED, Vector2(0,0))