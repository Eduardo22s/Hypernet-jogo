extends Area3D

func _on_area_entered(area: Area3D) -> void:
	if area is ChangeSceneDetector:
		$Fade/AnimationPlayer.play("fade")
		$"../Flash/S_ScreenFlashLayer/ScreenFlash".PlayFlash()
		MusicMenu.stop_music()
		
		await get_tree().create_timer(2.5).timeout
		await get_tree().process_frame
		get_tree().change_scene_to_file("res://scenes/stages/cutscene_beginning.tscn")
