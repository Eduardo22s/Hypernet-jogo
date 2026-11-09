extends Node3D

func _ready() -> void:
	Global.timer_on = true
	Global.tutorial = false
	MusicMenu.stop_music()
	
	await get_tree().create_timer(0.25).timeout
	MusicMenu.play_garden()
