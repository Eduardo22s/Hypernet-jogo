extends Node3D

@onready var state_machine: StateMachine = $StateMachine
@onready var patrol_state: PatrolState = $StateMachine/PatrolState
@onready var look_player_state: LookPlayerState = $StateMachine/LookPlayerState

@onready var player_exploration: PlayerExploration = $"../PlayerExploration"

@onready var look_player_zone: Area3D = $LookPlayerZone

var player_in_zone := false
var last_dialogue := true

var point_a: Node3D
var point_b: Node3D

@export var patrol_center: Node3D
@export var patrol_radius := 5.0


func _ready() -> void:
	Global.taking_damage.connect(_take_damage)

	# Pontos que estão no World
	point_a = get_parent().get_node("PointA")
	point_b = get_parent().get_node("PointB")

	look_player_state.player = player_exploration
	
	look_player_zone.body_entered.connect(_on_look_player_zone_body_entered)
	look_player_zone.body_exited.connect(_on_look_player_zone_body_exited)


func randomize_patrol_point(point: Node3D) -> void:
	if patrol_center == null:
		return

	var random_x := randf_range(-patrol_radius, patrol_radius)
	var random_z := randf_range(-patrol_radius, patrol_radius)

	point.global_position = patrol_center.global_position + Vector3(random_x,0.0,random_z)


func _on_interect_zone_body_entered(body: Node3D) -> void:
	if body is PlayerExploration:
		player_in_zone = true
		state_machine.transition_to(look_player_state)


func _on_interect_zone_body_exited(body: Node3D) -> void:
	if body is PlayerExploration:
		player_in_zone = false
		last_dialogue = true
		state_machine.transition_to(patrol_state)


func _process(_delta: float) -> void:
	if player_in_zone and last_dialogue and Input.is_action_just_pressed("interagir"):
		to_battle()
		last_dialogue = false


func to_battle() -> void:
	Global.player_return_pos = player_exploration.global_position
	Global.npc_battle = "DD"
	Global.words_in_storage = 0
	Global.invert_bools(["trigger_dialogue", "stop_player"])
	$AudioStreamPlayer.play()

	await get_tree().create_timer(1.5).timeout
	$Portal.warp()


func _take_damage() -> void:
	$AnimationPlayer.play("damage")
	
	
func _on_look_player_zone_body_entered(body: Node3D) -> void:
	if body is PlayerExploration:
		look_player_state.player = body
		state_machine.transition_to(look_player_state)


func _on_look_player_zone_body_exited(body: Node3D) -> void:
	if body is PlayerExploration:
		state_machine.transition_to(patrol_state)
