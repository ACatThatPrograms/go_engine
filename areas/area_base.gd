extends Node2D

signal faded_in

## Scene load vars

var update_position = game_data.update_position
var player_load_position = game_data.player_load_position
var override_direction = game_data.arrival_direction
var play_open_sound = game_data.scene_play_open_sound

export (String) var music_id = ""

var faded_in = false
export (String) var start_sound = ""

export (Vector2) var default_load_position

func _init():
	pass

func _ready():
	modulate.r = 0
	modulate.g = 0
	modulate.b = 0
	pos_update()
	play_music()
	connect_to_signals()
	if start_sound && play_open_sound:
		audio.get_node("sfx").play_sound(dict.sfx_id[start_sound])
	elif !start_sound && play_open_sound:
		audio.get_node("sfx").play_sound(dict.sfx_id["[9]"])

func _process(delta):
	if !faded_in:
		fade_in()

func play_music():
	if music_id:
		if audio.get_node("music").currently_playing != dict.music_id[music_id] || music_id == "":
			print("PLAYING SONG :", dict.music_id[music_id] )
			audio.get_node("music").play_music(dict.music_id[music_id])
		else:
			pass

func pos_update():
	if update_position:
		if has_node("Over"):
			get_tree().get_nodes_in_group("party")[0].leader.position = player_load_position
			if override_direction != "":
				get_tree().get_nodes_in_group("party")[0].leader.load_sprite_dir = override_direction
				get_tree().get_nodes_in_group("party")[0].leader.set_direction()
		else:
			get_tree().get_nodes_in_group("party")[0].leader.position = player_load_position
			if override_direction != "":
				get_tree().get_nodes_in_group("party")[0].leader.load_sprite_dir = override_direction
				get_tree().get_nodes_in_group("party")[0].leader.set_direction()

func fade_in():
	if modulate.r < 1:
		modulate.r += game_data.fade_speed
		modulate.g += game_data.fade_speed
		modulate.b += game_data.fade_speed
	else:
		faded_in = true
		emit_signal("faded_in")

func remove_party_focus(): ## For scenes, and animations
	for x in get_tree().get_nodes_in_group("party")[0].party_members:
		x.get_node("camera").current = false
		x.switch_state("inactive")

func connect_text_box(function_name = null):
	if function_name == null:
		if !ui.text_box().is_connected("text_done", ui.text_box(), "_text_done"):
			ui.text_box().connect("text_done", ui.text_box(), "_text_done", [self], 4)
	else:
		ui.text_box().connect("text_done", self, function_name, [self], 4)

func connect_to_signals():
	connect("faded_in", get_tree().get_nodes_in_group("party")[0], "_scene_faded_in")