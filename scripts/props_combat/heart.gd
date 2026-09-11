extends Node3D

func _ready() -> void:
	Global.taking_damage.connect(_take_damage)

func _take_damage():
	$SubViewport/Heart2dModel/AnimatedHeart.play("hit")
	await get_tree().create_timer(2.0).timeout
	$SubViewport/Heart2dModel/AnimatedHeart.play("normal")
