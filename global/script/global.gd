extends Node

signal taking_damage

var stop_player = false

var trigger_dialogue = false
var trigger_battle = false
var npc_battle = ""

func invert_bools(var_names: Array):
	for var_name in var_names:
		set(var_name, not get(var_name))
