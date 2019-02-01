extends KinematicBody2D

var MAP_SPEED = 70
var TYPE = "CHARACTER"

var move_dir = Vector2(0,0)
var sprite_dir = "_down"

var last_pos = Vector2(0,0)

export (String) var load_sprite_dir

var texture_default = null

func _process(delta):
	npc_anim_check()
	npc_animation_handler_loop()
	sprite_dir_loop()

func _ready():
	set_direction()
	texture_default = $Sprite.texture
	add_to_group("entities")

func movement_loop():
	var motion = move_dir.normalized() * MAP_SPEED
	
	if move_dir == dir._up_right && !test_move(transform, dir._up_right * 2):
		move_and_slide(motion, Vector2(0,0))
	
	elif move_dir == dir._right && !test_move(transform, dir._right * 2):
		move_and_slide(motion, Vector2(0,0))
	
	elif move_dir == dir._down_right && !test_move(transform, dir._down_right  * 2):
		move_and_slide(motion, Vector2(0,0))

	elif move_dir == dir._left && !test_move(transform, dir._left  * 2):
		move_and_slide(motion, Vector2(0,0))
	
	elif move_dir == dir._up_left && !test_move(transform, dir._up_left  * 2):
		move_and_slide(motion, Vector2(0,0))

	elif move_dir == dir._up && !test_move(transform, dir._up  * 2):
		move_and_slide(motion, Vector2(0,0))
	
	elif move_dir == dir._down_left && !test_move(transform, dir._down_left  * 2):
		move_and_slide(motion, Vector2(0,0))

	elif move_dir == dir._down && !test_move(transform, dir._down  * 2):
		move_and_slide(motion, Vector2(0,0))

func animation_handler_loop():
	if move_dir != dir._still && !test_move(transform, move_dir * 2):
		anim_switch("walk")
	else:
		anim_switch("idle")

func sprite_dir_loop():
	match move_dir:
		dir._up:
			sprite_dir = "_up"
		dir._up_right:
			sprite_dir = "_up_right"
		dir._right:
			sprite_dir = "_right"
		dir._down_right:
			sprite_dir = "_down_right"
		dir._down:
			sprite_dir = "_down"
		dir._down_left:
			sprite_dir = "_down_left"
		dir._left:
			sprite_dir = "_left"
		dir._up_left:
			sprite_dir = "_up_left"

func anim_switch(animation):
	if animation == "idle":
		$anim.stop(true)
	else:
		var newanim = str(animation, sprite_dir)
		if $anim.current_animation != newanim:
			$anim.play(newanim)

## ON Init

func set_direction():
	if load_sprite_dir == "left":
		sprite_dir = "_left"
		$Sprite.frame = 2
		$Sprite.flip_h = false
	if load_sprite_dir == "right":
		sprite_dir = "_right"
		$Sprite.frame = 2
		$Sprite.flip_h = true
	if load_sprite_dir == "up":
		sprite_dir = "_up"
		$Sprite.frame = 1
	if load_sprite_dir == "down":
		sprite_dir = "_down"
		$Sprite.frame = 0

## NPC ANIMATION CHECKS

func npc_anim_check():
	if TYPE == "NPC":
		if position == last_pos:
			move_dir = dir._still
		else:
			if position.x < last_pos.x:
				move_dir = dir._left
			elif position.x > last_pos.x:
				move_dir = dir._right
			elif position.y > last_pos.y:
				move_dir = dir._down
			elif position.y < last_pos.y:
				move_dir = dir._up
		last_pos = position
	else:
		pass

func npc_animation_handler_loop():
	if TYPE == "NPC":
		if move_dir != dir._still:
			anim_switch("walk")
		else:
			anim_switch("idle")
	else:
		pass