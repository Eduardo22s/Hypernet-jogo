extends Node3D

@onready var words = preload("res://scenes/props_combat/words.tscn")

@onready var spawner: Node3D = $"."

func _on_timer_timeout() -> void:
	spawn(spawner.global_position)

func spawn(pos):
	var w = words.instantiate() as Node3D
	
	if w:
		w.position = pos
	
	add_child(w)
