extends Node2D

const TYPE = "inspection_box"

export (String, MULTILINE) var text
export (String, MULTILINE) var t_char_0 # Command for char_0 only
export (String, MULTILINE) var t_char_1 # Command for char_1 only
export (String, MULTILINE) var t_char_2 # Command for char_2 only
export (String, MULTILINE) var t_char_3 # Command for char_3 only

export (String, MULTILINE) var custom_command # Custom command for text_box parser on inspection

var default_command = null
var command = null

var active_entity

func _ready():
	if text:
		command = "%s [wait] [end]" % text
		default_command = command
	elif custom_command:
		command = custom_command
		default_command = command

func _process(delta):
	for x in $hitbox.get_overlapping_areas():
		if x.get_parent().get("TYPE") == "PLAYER":
			active_entity = x.get_parent()
			match x.get_parent().char_id:
				0:
					if t_char_0 != null:
						command = t_char_0
					elif custom_command != null:
						command = custom_command
					else:
						command = default_command
				1:
					if t_char_1 != null:
						command = t_char_1
					elif custom_command != null:
						command = custom_command
					else:
						command = default_command
				2:
					if t_char_2 != null:
						command = t_char_2
					elif custom_command != null:
						command = custom_command
					else:
						command = default_command
				3:
					if t_char_3 != null:
						command = t_char_3
					elif custom_command != null:
						command = custom_command
					else:
						command = default_command
				_:
					command = default_command