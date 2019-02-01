extends Node

const _still = 		Vector2(0,0)
const _up = 		Vector2(0,-1)
const _right = 		Vector2(1,0)
const _down = 		Vector2(0, 1)
const _left = 		Vector2(-1,0)

const _up_right =	Vector2(1, -1)
const _up_left =	Vector2(-1,-1)
const _down_left =	Vector2(-1,1)
const _down_right =	Vector2(1,1)

func rand():
	var d = randi() % 4 + 1
	match d:
		1:
			return _left
		2:
			return _right 
		3:
			return _up
		4:
			return _down