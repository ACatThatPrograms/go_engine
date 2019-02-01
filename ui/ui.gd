extends CanvasLayer

onready var player_menu 	=	$player_menu
onready var goods_menu 		=	$goods_menu
onready var goods_sub_menu	=	$goods_menu/goods_sub_menu
onready var text_box 		=	$text_box
onready var funds_box 		=	$funds_box
onready var status_blocks	=	$status_blocks

signal player_menu_opened
signal player_menu_closed

signal goods_menu_opened
signal goods_menu_closed

signal funds_opened
signal funds_closed

signal status_blocks_opened
signal status_blocks_closed

var active_entity = null

func _ready():
	#Connects for player_menu
	connect("player_menu_opened", $player_menu, "_player_menu_opened")
	connect("player_menu_closed", $player_menu, "_player_menu_closed")
	#Connects for goods menu
	connect("goods_menu_opened", $goods_menu, "_goods_menu_opened")
	connect("goods_menu_closed", $goods_menu, "_goods_menu_closed")
	#Connects for funds box
	connect("funds_closed", $funds_box, "_funds_box_closed")
	connect("goods_menu_opened", $funds_box, "_goods_menu_opened")
	connect("player_menu_closed", $funds_box, "_player_menu_closed")
	#Connects status box
	connect("status_blocks_opened", $status_blocks, "_status_blocks_opened")
	connect("status_blocks_closed", $status_blocks, "_status_blocks_closed")
	connect("player_menu_closed", $status_blocks, "_player_menu_closed")
	connect("goods_menu_opened", $status_blocks, "_goods_menu_opened")

## Player Menu
func open_player_menu(opening_entity):
	player_menu.open(opening_entity)
	emit_signal("player_menu_opened")

func close_player_menu():
	emit_signal("player_menu_closed")

## Goods Menu

func open_goods_menu(opening_entity):
	goods_menu.open(opening_entity)
	emit_signal("goods_menu_opened")

func close_goods_menu():
	emit_signal("goods_menu_closed")

## Status Blocks

func open_status_blocks(opening_entity):
	status_blocks.open(opening_entity)
	emit_signal("status_blocks_opened")

func close_status_blocks():
	emit_signal("status_blocks_closed")

## Funds Box

func open_funds(opening_entity):
	funds_box.open(opening_entity)

func close_funds():
	funds_box.close()


## Combo Function for B Button

func open_status_and_funds(opening_entity):
	open_status_blocks(opening_entity)
	open_funds(opening_entity)

## Status Menu

func open_status_menu(opening_entity):
	$status_menu.open(opening_entity)

func close_status_menu():
	$status_menu.close()

## Text Box Functions


## Object returns

func text_box():
	return text_box

func goods_menu():
	return goods_menu