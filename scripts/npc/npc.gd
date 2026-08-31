extends Node3D

func _ready() -> void:
	Global.taking_damage.connect(_take_damage)

func _take_damage():
	$AnimationPlayer.play("damage")

func _on_interect_zone_body_entered(body: Node3D) -> void:
	if body is PlayerExploration:
		Global.npc_battle = "test"
		Global.invert_bools(["trigger_dialogue", "stop_player"])
