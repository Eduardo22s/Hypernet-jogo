extends Node3D

@onready var words_good = preload("res://scenes/props_combat/words_good.tscn")
@onready var words_neutral = preload("res://scenes/props_combat/words_neutral.tscn")
@onready var words_bad = preload("res://scenes/props_combat/words_bad.tscn")

@onready var spawner: Node3D = $"."

var random_pos = Vector3(randf_range(-7.5, 7.5), 0, randf_range(-7.5, 7.5))
var wave_breaker_1 = true
var wave_breaker_2 = true
var wave_breaker_3 = true


func _process(_delta: float) -> void:
	if Global.words_in_storage >= 3:
		queue_free()

	match Global.words_in_storage:
		0:
			await get_tree().create_timer(6.5).timeout
			if wave_breaker_1:
				spawn(spawner.global_position, "good")
				spawn(spawner.global_position, "neutral")
				spawn(spawner.global_position, "bad")
				random_pos = Vector3(randf_range(-7.5, 7.5), 0, randf_range(-7.5, 7.5))
				wave_breaker_1 = false
		1:
			await get_tree().create_timer(6.5).timeout
			if wave_breaker_2:
				Global.word_selected = false
				spawn(spawner.global_position, "good")
				spawn(spawner.global_position, "neutral")
				spawn(spawner.global_position, "bad")
				random_pos = Vector3(randf_range(-7.5, 7.5), 0, randf_range(-7.5, 7.5))
				wave_breaker_2 = false
		2:
			await get_tree().create_timer(6.5).timeout
			if wave_breaker_3:
				Global.word_selected = false
				spawn(spawner.global_position, "good")
				spawn(spawner.global_position, "neutral")
				spawn(spawner.global_position, "bad")
				random_pos = Vector3(randf_range(-7.5, 7.5), 0, randf_range(-7.5, 7.5))
				wave_breaker_3 = false


func spawn(pos, type):
	var wg = words_good.instantiate()
	var wn = words_neutral.instantiate()
	var wb = words_bad.instantiate()
	
	pos = random_pos
	
	wg.position = pos
	wn.position = pos
	wb.position = pos
	
	if type == "good":
		get_parent().add_child(wg)
		random_pos = Vector3(randf_range(-7.5, 7.5), 0, randf_range(-7.5, 7.5))
	elif type == "neutral":
		get_parent().add_child(wn)
		random_pos = Vector3(randf_range(-7.5, 7.5), 0, randf_range(-7.5, 7.5))
	else:
		get_parent().add_child(wb)
		random_pos = Vector3(randf_range(-7.5, 7.5), 0, randf_range(-7.5, 7.5))
