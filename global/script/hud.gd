extends Control

var break_animation = false
var last_stage_label = -1


func _process(_delta: float) -> void:
	InCombatLabels()
	
	if Global.trigger_dialogue:
		$Dialogues/TestDialogue/AnimationDialogue.play("call_textbox")

		await get_tree().create_timer(1.5).timeout
		Global.trigger_dialogue = false

		await get_tree().create_timer(3.5).timeout
		Global.trigger_battle = true
		Global.npc_battle = "test"


func InCombatLabels():
	if Global.words_in_storage == last_stage_label:
		return

	last_stage_label = Global.words_in_storage

	match Global.words_in_storage:
		0:
			$Combat/InStageLabels.play("RESET")
		1:
			$Combat/InStageLabels.play("intro")
		2:
			$Combat/InStageLabels.play("midfase")
		3:
			$Combat/InStageLabels.play("farewell")
