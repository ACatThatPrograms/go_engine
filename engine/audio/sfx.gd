extends AudioStreamPlayer

func _ready():
	pass

func play_sound(sound_path):
	stream = load(sound_path)
	play()