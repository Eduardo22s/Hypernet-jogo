extends Node

signal taking_damage

var menu_intro_played := false

var tutorial = true
var crt = true
var music_mute = false
var sfx_mute = false

var stop_player = false
var end_game = false

var trigger_dialogue = false
var trigger_battle = false
var exit_dialogue = false
var npc_battle = ""

var DD_concluded = false
var show_DD_profile = false

var word_kind = ""
var words_in_storage = 0
var good_results = 0
var neutral_results = 0
var bad_results = 0
var word_selected = false

#var player_return_pos = Vector3(-0.235, 5.0, 0.525)

var points = 0
var checkpoints = 0
var checkpoint_pos = Vector3()
var checkpoint_in_scene = false

var timer_on = false
var seconds = 0

var which_way = ""


func _process(delta: float) -> void:
	if !timer_on:
		return
	else:
		seconds += delta
		if end_game:
			seconds = seconds
			timer_on = false

func reset_timer():
	timer_on = false
	seconds = 0


func invert_bools(var_names: Array):
	for var_name in var_names:
		set(var_name, not get(var_name))
