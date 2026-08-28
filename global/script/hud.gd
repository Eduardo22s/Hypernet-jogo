extends Control

func _process(_delta: float) -> void:
	if Global.trigger_dialogue:
		$Dialogues/TestDialogue/AnimationDialogue.play("call_textbox")
		await get_tree().create_timer(1.5).timeout
		Global.trigger_dialogue = false
		await get_tree().create_timer(3.5).timeout
		Global.trigger_battle = true
		Global.npc_battle = "test"
