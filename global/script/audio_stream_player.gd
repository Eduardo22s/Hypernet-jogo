extends AudioStreamPlayer

@export var volume := 0.0

func _process(_delta: float) -> void:
	if Global.sfx_mute == true:
		volume_db = -80.0
	elif Global.sfx_mute == false:
		volume_db = volume
