extends Node3D

var player_in_zone = false

@onready var player_exploration: PlayerExploration = $"../PlayerExploration"


func _ready() -> void:
	Global.taking_damage.connect(_take_damage)

func _process(_delta: float) -> void:
	if player_in_zone && Input.is_action_just_pressed("interagir"):
			Global.player_return_pos = player_exploration.global_position
			Global.npc_battle = "test"
			Global.invert_bools(["trigger_dialogue", "stop_player"])
			$AudioStreamPlayer.play()
			await get_tree().create_timer(1.5).timeout
			$Portal.warp()


func _on_interect_zone_body_entered(body: Node3D) -> void:
	if body is PlayerExploration:
		player_in_zone = true

func _on_interect_zone_body_exited(body: Node3D) -> void:
	if body is PlayerExploration:
		player_in_zone = false


func _take_damage():
	$AnimationPlayer.play("damage")
