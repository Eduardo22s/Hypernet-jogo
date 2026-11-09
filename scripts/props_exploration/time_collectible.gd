extends Area3D

@export var bonus_seconds: int

func _on_area_3d_area_entered(area: Area3D) -> void:
	if area is BumperDetector:
		Global.seconds += bonus_seconds
		$AnimatedSprite3D.visible = false
		$Bubble.visible = false
		$AnimatedSprite3D2.play("Pop")
		$AudioStreamPlayer.play()
		$Area3D.queue_free()
		
		await get_tree().create_timer(1.0).timeout
		self.queue_free()
