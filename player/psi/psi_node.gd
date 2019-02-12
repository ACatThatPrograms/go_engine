extends Node2D

var psi_list = []
var psi_base

func init_psi_nodes():
	psi_base = preload("res://engine/psi/psi_base.gd").new()
	psi_list = get_parent().psi
	psi_list.sort()
	
	for x in psi_list:
		add_child(psi_base.fetch_psi(x))