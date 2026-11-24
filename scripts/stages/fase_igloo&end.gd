extends Node3D

func _ready() -> void:
	Global.checkpoint_in_scene = false
	MusicMenu.stop_music()
	
	await get_tree().create_timer(0.25).timeout
	MusicMenu.play_igloo()
