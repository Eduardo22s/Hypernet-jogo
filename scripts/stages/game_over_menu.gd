extends Control

func _ready() -> void:
	$Fade/AnimationPlayer.play_backwards("fade")
	$DeathAnimation/AnimationPlayer.play("death")
	
	Global.reset_timer()
	MusicMenu.stop_music()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("menu"):
		$ButtonMenu/MainMenuLabel.visible = false
		$ButtonMenu/MainMenuSelected.visible = true
		$Flash/S_ScreenFlashLayer/ScreenFlash.PlayFlash()
		$Fade/AnimationPlayer.play("fade")
		$AudioStreamPlayer2.play()
		MusicMenu.play_theme()
		
		await get_tree().create_timer(2.5).timeout
		get_tree().change_scene_to_file("res://scenes/stages/main_menu.tscn")
	
	if Input.is_action_just_pressed("ui_accept"):
		$ButtonReplay/ReplayLabel.visible = false
		$ButtonReplay/ReplaySelected.visible = true
		$Flash/S_ScreenFlashLayer/ScreenFlash.PlayFlash()
		$Fade/AnimationPlayer.play("fade")
		$AudioStreamPlayer2.play()
		
		await get_tree().create_timer(2.5).timeout
		get_tree().change_scene_to_file("res://scenes/stages/fase_jardim.tscn")


func _on_button_menu_mouse_entered() -> void:
	$ButtonMenu/MainMenuLabel.scale = Vector2(1.25, 1.25)

func _on_button_menu_mouse_exited() -> void:
	$ButtonMenu/MainMenuLabel.scale = Vector2(1.0, 1.0)

func _on_button_menu_pressed() -> void:
	$ButtonMenu/MainMenuLabel.visible = false
	$ButtonMenu/MainMenuSelected.visible = true
	$Flash/S_ScreenFlashLayer/ScreenFlash.PlayFlash()
	$Fade/AnimationPlayer.play("fade")
	
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_file("res://scenes/stages/main_menu.tscn")


func _on_button_replay_mouse_entered() -> void:
	$ButtonReplay/ReplayLabel.scale = Vector2(1.25, 1.25)

func _on_button_replay_mouse_exited() -> void:
	$ButtonReplay/ReplayLabel.scale = Vector2(1.0, 1.0)

func _on_button_replay_pressed() -> void:
	Global.reset_timer()
	Global.end_game = false
	
	$ButtonReplay/ReplayLabel.visible = false
	$ButtonReplay/ReplaySelected.visible = true
	$Flash/S_ScreenFlashLayer/ScreenFlash.PlayFlash()
	$Fade/AnimationPlayer.play("fade")
	
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_file("res://scenes/stages/fase_jardim.tscn")
