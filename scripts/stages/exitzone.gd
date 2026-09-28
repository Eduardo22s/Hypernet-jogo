extends Area3D


func _on_body_entered(body: Node3D) -> void:
	if body is PlayerCombat:
		Global.invert_bools(["trigger_battle", "stop_player"])
		Global.words_in_storage = 0
		
		await get_tree().process_frame
		get_tree().change_scene_to_file("res://scenes/stages/fase.tscn")
