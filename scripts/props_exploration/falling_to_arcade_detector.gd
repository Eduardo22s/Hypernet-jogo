extends Area3D

func _on_body_entered(body: Node3D) -> void:
	if body is PlayerExploration:
		Global.which_way = "fall_to_arcade"
		$"../Fade/AnimationPlayer".play("fade")
		$"../Flash/S_ScreenFlashLayer/ScreenFlash".PlayFlash()
		
		await get_tree().create_timer(2.5).timeout
		await get_tree().process_frame
		get_tree().change_scene_to_file("res://scenes/stages/fase_fliperama.tscn")
