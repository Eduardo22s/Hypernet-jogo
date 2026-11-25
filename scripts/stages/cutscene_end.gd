extends Node2D

func _ready() -> void:
	$Fade/AnimationPlayer.play_backwards("fade")
	MusicMenu.stop_music()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		await get_tree().process_frame
		get_tree().change_scene_to_file("res://scenes/stages/game_over_menu.tscn")

func _on_video_stream_player_finished() -> void:
	MusicMenu.play_theme()
	await get_tree().process_frame
	get_tree().change_scene_to_file("res://scenes/stages/game_over_menu.tscn")
