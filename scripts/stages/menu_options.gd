extends Node2D


func _on_button_mute_audio_pressed() -> void:
	$AnimatedMuteAudio.frame = 1


func _on_button_mute_music_pressed() -> void:
	$AnimatedMuteMusic.frame = 1


func _on_button_crt_filter_pressed() -> void:
	$AnimatedCRTFilter.frame = 1


func _on_button_return_mouse_entered() -> void:
	$AnimatedReturn.frame = 1

func _on_button_return_mouse_exited() -> void:
	$AnimatedReturn.frame = 0

func _on_button_return_pressed() -> void:
	$AnimatedReturn.frame = 1

	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_file("res://scenes/stages/main_menu.tscn")



func _on_button_controls_mouse_entered() -> void:
	$AnimatedControls.frame = 1

func _on_button_controls_mouse_exited() -> void:
	$AnimatedControls.frame = 0

func _on_button_controls_pressed() -> void:
	$AnimatedControls.frame = 1

	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_file("res://scenes/stages/menu_controls.tscn")
