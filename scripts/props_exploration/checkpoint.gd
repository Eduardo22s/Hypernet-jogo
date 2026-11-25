extends Node3D

func _process(_delta: float) -> void:
	if $AnimatedSprite3D2.frame == 7:
		$AnimatedSprite3D2.visible = false
		$AnimatedSprite3D.visible = true
