extends Node2D

func _on_button_return_mouse_entered() -> void:
	$AnimatedReturn.frame = 1

func _on_button_return_mouse_exited() -> void:
	$AnimatedReturn.frame = 0

func _on_button_return_pressed() -> void:
	$AnimatedReturn.frame = 1

	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_file("res://scenes/stages/menu_options.tscn")
