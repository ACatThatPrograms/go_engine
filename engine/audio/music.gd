extends AudioStreamPlayer

var currently_playing = ""

func _ready():
	if engine.MUTE_MUSIC:
		volume_db = -80

func play_music(music_path):
	currently_playing = music_path
	stream = load(music_path)
	play()