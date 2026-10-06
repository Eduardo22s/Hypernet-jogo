class_name LookPlayerState
extends State

@export var rotation_speed := 5.0

var player: PlayerExploration
var model: Node3D


func enter() -> void:
	model = npc.get_node("Day_Dream")


func update(delta: float) -> void:
	if not is_instance_valid(player):
		return

	var target_position := player.global_position
	target_position.y = npc.global_position.y

	var direction := target_position - npc.global_position

	if direction.length() < 0.01:
		return

	var target_angle := atan2(direction.x, direction.z) 

	model.rotation.y = lerp_angle(model.rotation.y,target_angle,rotation_speed * delta)
