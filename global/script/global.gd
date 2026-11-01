extends Node

signal taking_damage

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

var player_return_pos = Vector3(1.8, 1.6, 7.0)

var timer_on = false
var minutes = 5
var seconds = 59


func _process(delta: float) -> void:
	if not timer_on:
		return

	seconds -= delta

	while seconds < 0 and minutes > 0:
		minutes -= 1
		seconds += 60

	if minutes <= 0 and seconds <= 0:
		Global.end_game = true
		minutes = 0
		seconds = 0


func reset_timer():
	timer_on = false
	minutes = 5
	seconds = 59

func invert_bools(var_names: Array):
	for var_name in var_names:
		set(var_name, not get(var_name))
		

func add_time(amount: int):
	var total_seconds = minutes * 60 + int(ceil(seconds)) + amount

	minutes = int(total_seconds / 60)
	seconds = float(total_seconds % 60)
