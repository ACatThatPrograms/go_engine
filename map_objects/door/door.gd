extends Node2D

signal scene_door_activated

## Target Scene as Resource Path
export (String) var target_scene

export (Vector2) var target_position
export (String) var arrival_dir = "" #Must be up, down, left, right

export (bool) var play_sound_on_open = true
export (String) var open_sound_id

## Anim Vars

var start_fade = false

func _ready():
	if !open_sound_id:
		open_sound_id = "[8]"
	connect("scene_door_activated", game_data, "scene_door_activated", [self, target_position, arrival_dir, play_sound_on_open], 4)

func _process(delta):
	if start_fade:
		if get_parent().modulate.r > 0:
			get_parent().modulate.r -= game_data.fade_speed
			get_parent().modulate.g -= game_data.fade_speed
			get_parent().modulate.b -= game_data.fade_speed
		else:
			emit_signal("scene_door_activated")
		
	else:
		for obj in $hitbox.get_overlapping_areas():
			if obj.get_parent().get("TYPE") == "PLAYER":
				obj.get_parent().anim_switch("idle")
				obj.get_parent().switch_state("inactive")
				audio.get_node("sfx").play_sound(dict.sfx_id[open_sound_id])
				
				start_fade = true

func data_update_done():
	print("UPDATE_DONE")
	get_tree().change_scene(target_scene)

func fade_scene():
	pass