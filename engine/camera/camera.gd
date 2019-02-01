extends Camera2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	pass

func _process(delta):
	if engine.DEBUG:
		if Input.is_action_just_pressed("debug_zoom_in"):
			zoom -= Vector2(.05,.05)
		if Input.is_action_just_pressed("debug_zoom_out"):
			zoom += Vector2(.05,.05)
