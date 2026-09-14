extends Node3D

@onready var WaterDrips: GPUParticles3D = $WaterDrips

func Destroy():
	WaterDrips.reparent(get_parent(), true)
	WaterDrips.emitting = true
	queue_free()
