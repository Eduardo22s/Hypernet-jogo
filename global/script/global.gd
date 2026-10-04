extends Node

signal taking_damage

var stop_player = false
var end_game = false

var trigger_dialogue = false
var trigger_battle = false
var npc_battle = ""

var word_kind = ""
var words_in_storage = 0
var good_results = 1
var neutral_results = 0
var bad_results = 0

var player_return_pos = Vector3(1.8, 1.6, 7.0)

var timer_on = false
var minutes = 5
var seconds = 59


func _process(delta: float) -> void:
	if timer_on:
		seconds -= 1 * delta
		if minutes != 0 and seconds == 0:
			minutes -= 1
			seconds += 59
		elif minutes == 0 and seconds == 0:
			Global.end_game = true
			minutes = 0
			seconds = 0
	else:
		return

func invert_bools(var_names: Array):
	for var_name in var_names:
		set(var_name, not get(var_name))
