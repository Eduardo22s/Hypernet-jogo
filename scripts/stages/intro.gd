extends Node2D

func _process(_delta: float) -> void:
	await get_tree().create_timer(2.0).timeout
	$AnimatedSprite2D.play("default")
	
	if $AnimatedSprite2D.frame == 9:
		await get_tree().process_frame
		get_tree().change_scene_to_file("res://cenas/stages/fase.tscn")
