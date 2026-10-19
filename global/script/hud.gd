extends Control

var break_animation = false
var last_stage_label = -1
var game_paused = false

var intro = true
var question1 = true
var question2 = true
var question3 = true
var call_once = false

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

	if Global.show_DD_profile:
		$Profiles/DD.visible = true
	else:
		$Profiles/DD.visible = false

	if Global.trigger_dialogue && Global.npc_battle == "DD":
		if intro:
			$Dialogues/AnimationDialogue.play("CallDD")
			intro = false

		if Input.is_action_just_pressed("attack") && !intro:
			$Dialogues/AnimationDialogue.play("DDDecline")
			Global.exit_dialogue = true
			Global.trigger_dialogue = false
			Global.stop_player = false

		elif Input.is_action_just_pressed("interagir") && !intro:
			$Dialogues/AnimationDialogue.play("DDAccept")
			
			await get_tree().create_timer(5.0).timeout
			Global.trigger_battle = true

	if Global.trigger_battle == true && Global.npc_battle == "DD":
		match Global.words_in_storage:
			0:
				if question1:
					$Dialogues/AnimationDialogue.play("DDQuestion1")
					
					await get_tree().create_timer(6.5).timeout
					question1 = false
			1:
				if question2:
					$Dialogues/AnimationDialogue.play("DDQuestion2")
					
					await get_tree().create_timer(6.5).timeout
					question2 = false
			2:
				if question3:
					$Dialogues/AnimationDialogue.play("DDQuestion3")
					
					await get_tree().create_timer(6.5).timeout
					question3 = false
			3:
				$Dialogues/AnimationDialogue.play("DDConclusion")
	#if Global.DD_concluded: 
	#	$Dialogues/AnimationDialogue.play("DDConclusion")


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
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


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
