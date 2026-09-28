extends Node3D

@onready var words_good = preload("res://scenes/props_combat/words_good.tscn")
@onready var words_neutral = preload("res://scenes/props_combat/words_neutral.tscn")
@onready var words_bad = preload("res://scenes/props_combat/words_bad.tscn")

@onready var spawner: Node3D = $"."

var random_pos = Vector3(randf_range(-8, 8), 0, randf_range(-8, 8))
var random_word = randi_range(1, 10)

func _process(_delta: float) -> void:
	if Global.words_in_storage >= 3:
		queue_free()

func _on_timer_timeout() -> void:
	spawn(spawner.global_position)
	random_pos = Vector3(randf_range(-8, 8), 0, randf_range(-8, 8))
	random_word = randi_range(1, 10)

func spawn(pos):
	var wg = words_good.instantiate()
	var wn = words_neutral.instantiate()
	var wb = words_bad.instantiate()
	
	pos = random_pos
	
	wg.position = pos
	wn.position = pos
	wb.position = pos
	
	if random_word < 4:
		get_parent().add_child(wg)
	elif random_word < 8:
		get_parent().add_child(wn)
	else:
		get_parent().add_child(wb)
