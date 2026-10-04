extends Node2D

func _on_button_play_pressed() -> void:
	$AnimatedMenu.frame = 1
	
	await get_tree().create_timer(2.0).timeout
	get_tree().change_scene_to_file("res://scenes/stages/intro.tscn")


func _on_button_options_pressed() -> void:
	pass # Replace with function body.


func _on_button_credits_pressed() -> void:
	pass # Replace with function body.


func _on_button_exit_pressed() -> void:
	$AnimatedMenu.frame = 4
	
	await get_tree().create_timer(2.0).timeout
	get_tree().quit()
