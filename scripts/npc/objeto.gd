extends StaticBody3D

func _ready() -> void:
	Global.taking_damage.connect(_take_damage)

func _on_interect_zone_body_entered(body: Node3D) -> void:
	if body is PlayerExploration:
		Global.npc_battle = "test"
		Global.invert_bools(["trigger_dialogue", "stop_player"])

func _take_damage():
	$Sprite3D.modulate = Color.BLUE
	await get_tree().create_timer(1.0).timeout
	$Sprite3D.modulate = Color.WHITE
