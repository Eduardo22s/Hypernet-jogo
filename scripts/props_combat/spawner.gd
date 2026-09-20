extends Node3D

@onready var words = preload("res://scenes/props_combat/words_good.tscn")
@onready var spawner: Node3D = $"."

var random_pos = Vector3(randf_range(-8, 8), 0, randf_range(-8, 8))

func _on_timer_timeout() -> void:
	spawn(spawner.global_position)

func spawn(pos):
	var w = words.instantiate()
	pos = random_pos
	
	if w:
		w.position = pos
	
	get_parent().add_child(w)
