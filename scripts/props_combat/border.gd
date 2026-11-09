extends Area3D
class_name Border

@export var radius: float = 10.0

@onready var sprite: AnimatedSprite3D = $AnimatedSprite3D

func _ready():
	add_to_group("player_bumpers")
	sprite.play("Idle")

func _on_body_entered(body: Node3D) -> void:
	if body is PlayerExploration:
		$AnimationPlayer.play("action")

func _on_area_entered(area: Area3D) -> void:
	if area is BumperDetector:
		$AnimationPlayer.play("action")
