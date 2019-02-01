extends "res://engine/entity.gd"

### RANGE player.position.x - 1.5 <= position.x && position.x <= player.position.x + 1.5:

var state = "following"

onready var player = get_tree().get_nodes_in_group("player")[0]

var frame_offset = 14

var player_trail = []
var player_last_pos = Vector2(0,0)
var position_index = 0
var last_pos = Vector2(0,0)

func _ready():
	position = player.position
	player_last_pos = player.position
	last_pos = player.position
	for x in frame_offset:
		player_trail.append([player.position, player.move_dir])

func _process(delta):
	match state:
		"following":
			animation_handler_loop()
			check_trail_cache()
			sprite_dir_loop()

func check_trail_cache():
	if player_last_pos != player.position:
		position = player_trail[0][0]
		move_dir = player_trail[0][1]
	
		if position_index < frame_offset:
			position_index += 1
		else:
			position_index = 0
		
		if player_trail.size() > frame_offset:
			player_trail.pop_front()
		player_trail.push_back([player.position, player.move_dir])
		
		last_pos = position
	
	else:
		move_dir = Vector2(0,0)

	player_last_pos = player.position