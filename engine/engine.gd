extends Node

const DEBUG = true
const MUTE_MUSIC = false

const party_count_max = 10 # Used to set-up default frame indices for follower logic

func _process(delta):
	if Input.is_action_just_pressed("engine_debug_mode_toggle"):
		DEBUG = !DEBUG
		print("Main Engine Debug Enabled: " , DEBUG)