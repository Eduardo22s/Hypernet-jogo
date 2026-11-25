extends Control

var rank = 1

func _ready() -> void:
	$Fade/AnimationPlayer.play_backwards("fade")
	$DeathAnimation/AnimationPlayer.play("death")
	$JumpCounter/Label.text = str(Global.how_many_jumps)
	$DashCounter/Label.text = str(Global.how_many_dashes)
	
	Global.reset_timer()
	MusicMenu.stop_music()
	
	await get_tree().create_timer(8.0).timeout
	$AudioStreamPlayer2.play()
	$AnimatedSprite2D.frame = 1
	
	if Global.seconds < 300:
		await get_tree().create_timer(2.0).timeout
		$AudioStreamPlayer2.play()
		$AnimatedSprite2D2.frame = 1
		rank += 1

	if !Global.checkpoint_used:
		await get_tree().create_timer(2.0).timeout
		$AudioStreamPlayer2.play()
		$AnimatedSprite2D3.frame = 1
		rank += 1

	if rank <= 1:
		await get_tree().create_timer(2.0).timeout
		$AudioStreamPlayer3.play()
		$Rank/AnimatedSprite2D.visible = true
		$Rank/AnimatedSprite2D.frame = 0
	elif rank <= 2:
		await get_tree().create_timer(2.0).timeout
		$AudioStreamPlayer3.play()
		$Rank/AnimatedSprite2D.visible = true
		$Rank/AnimatedSprite2D.frame = 1
	else:
		await get_tree().create_timer(2.0).timeout
		$AudioStreamPlayer3.play()
		$Rank/AnimatedSprite2D.visible = true
		$Rank/AnimatedSprite2D.frame = 2
	
	
	await get_tree().create_timer(5.0).timeout
	$Flash/S_ScreenFlashLayer/ScreenFlash.PlayFlash()
	$Fade/AnimationPlayer.play("fade")
	$AudioStreamPlayer2.play()
	
	await get_tree().create_timer(2.5).timeout
	await get_tree().process_frame
	get_tree().change_scene_to_file("res://scenes/stages/credits_screen.tscn")
