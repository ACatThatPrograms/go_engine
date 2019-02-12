extends "res://engine/entity.gd"

export(String) var movement_type = "wander"

var default_speak
var active_entity # Person speaking with

var battle_light

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
	SUB_TYPE = "ENEMY"
	MAP_SPEED = 20

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
						check_for_player()
					"still":
						still()
					"load_battle":
						load_battle()
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

###################
## CHECK PLAYER  ##
###################

func check_for_player():
	for x in $hitbox.get_overlapping_areas():
		if x.get_parent().TYPE == "PLAYER":
			for x in get_tree().get_nodes_in_group("entities"):
				x.switch_state("inactive")
			var light_fx = preload("res://engine/light_effects/battle_light.tscn").instance()
			light_fx.name = "light"
			add_child(light_fx)
			battle_light = get_node("light").get_node("Light2D")
			movement_type = "load_battle"
			switch_state("active")

func load_battle():
	print(battle_light.name)

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