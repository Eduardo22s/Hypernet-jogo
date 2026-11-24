extends Node2D

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		await get_tree().process_frame
		get_tree().change_scene_to_file("res://scenes/stages/fase_jardim.tscn")

func _on_video_stream_player_finished() -> void:
	await get_tree().process_frame
	get_tree().change_scene_to_file("res://scenes/stages/fase_jardim.tscn")
