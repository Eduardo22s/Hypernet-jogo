extends Control

var break_animation = false
var last_stage_label = -1
var game_paused = false


func _on_button_main_menu_pressed() -> void:
	get_tree().paused = false
	
	await get_tree().process_frame
	get_tree().change_scene_to_file.call_deferred("res://scenes/stages/main_menu.tscn")

func _on_button_quit_pressed() -> void:
	await get_tree().process_frame
	get_tree().quit()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("menu") and not event.is_echo():
		get_viewport().set_input_as_handled()
		if game_paused:
			close_menu()
		else:
			open_menu()

func _process(_delta: float) -> void:
	InCombatLabels()
	$TimerSprite/Label.text = str(Global.minutes, ":", roundi(Global.seconds))

	if Global.trigger_dialogue:
		$Dialogues/TestDialogue/AnimationDialogue.play("call_textbox")

		await get_tree().create_timer(1.5).timeout
		Global.trigger_dialogue = false

		await get_tree().create_timer(3.5).timeout
		Global.trigger_battle = true

func open_menu() -> void:
	game_paused = true
	get_tree().paused = true
	$AnimatedPause.play("open")

	await get_tree().create_timer(1.0).timeout
	if game_paused:
		_set_buttons(true)

func close_menu() -> void:
	game_paused = false
	_set_buttons(false)
	$AnimatedPause.play("close")
	get_tree().paused = false


func InCombatLabels():
	if Global.words_in_storage == last_stage_label:
		return

	last_stage_label = Global.words_in_storage

	match Global.words_in_storage:
		1:
			$Combat/Letters/InStageLabels.play("intro")
			$Combat/WaveBar.visible = true
			$Combat/Answer1.play(Global.word_kind)
		2:
			$Combat/Letters/InStageLabels.play("midfase")
			$Combat/WaveBar2.visible = true
			$Combat/Answer2.play(Global.word_kind)
		3:
			$Combat/Letters/InStageLabels.play("farewell")
			$Combat/WaveBar3.visible = true
			$Combat/Answer3.play(Global.word_kind)


func _toggle_pause() -> void:
		get_tree().paused = !get_tree().paused

func _set_buttons(show_buttons: bool) -> void:
	$ButtonMainMenu.visible = show_buttons
	$ButtonQuit.visible = show_buttons
	$ButtonMainMenu.disabled = !show_buttons
	$ButtonQuit.disabled = !show_buttons
