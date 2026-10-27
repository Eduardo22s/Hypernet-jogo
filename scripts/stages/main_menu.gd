extends Node2D

func _ready() -> void:
	Global.reset_timer()


func _on_button_play_mouse_entered() -> void:
	$AnimatedPlay.frame = 1

func _on_button_play_mouse_exited() -> void:
	$AnimatedPlay.frame = 0

func _on_button_play_pressed() -> void:
	$AnimatedPlay.frame = 1
	
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_file("res://scenes/stages/intro.tscn")



func _on_button_options_mouse_entered() -> void:
	$AnimatedOptions.frame = 1

func _on_button_options_mouse_exited() -> void:
	$AnimatedOptions.frame = 0

func _on_button_options_pressed() -> void:
	$AnimatedOptions.frame = 1

	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_file("res://scenes/stages/menu_options.tscn")



func _on_button_credits_mouse_entered() -> void:
	$AnimatedCredits.frame = 1

func _on_button_credits_mouse_exited() -> void:
	$AnimatedCredits.frame = 0

func _on_button_credits_pressed() -> void:
	$AnimatedCredits.frame = 1

	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_file("res://scenes/stages/menu_credits.tscn")


func _on_button_exit_mouse_entered() -> void:
	$AnimatedExit.frame = 1

func _on_button_exit_mouse_exited() -> void:
	$AnimatedExit.frame = 0

func _on_button_exit_pressed() -> void:
	$AnimatedExit.frame = 1
	
	await get_tree().create_timer(1.0).timeout
	get_tree().quit()
