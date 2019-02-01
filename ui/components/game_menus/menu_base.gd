extends NinePatchRect

# Inherited initial hide state of menus, change in individual menus
var should_hide = true

# Global Arrow Blink Rate Setting :: Lower == Faster
var arrow_blink_rate_init = 8
var arrow_blink_rate = arrow_blink_rate_init

# Signals if menu is ready for input
# By default menus wait 1 frame before setting true, and reset to false on close
# Fixes input repetition on menu switching
var ready_for_input = false

# Inherited initial state for menus unless set otherwise
var state = "inactive"

func _ready():
	hider()

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

func hider():
	if should_hide:
		hide()