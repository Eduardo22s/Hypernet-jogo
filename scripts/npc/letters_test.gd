extends Node3D

func _on_hitzone_area_entered(area: Area3D) -> void:
	if area is Attack: 
		Global.emit_signal("taking_damage")
