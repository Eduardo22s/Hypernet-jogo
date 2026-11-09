extends Node3D

func _ready() -> void:
	play_theme()

func _process(_delta: float) -> void:
	if Global.music_mute:
		$AudioStreamPlayer.volume_db = -80.0
		$AudioStreamPlayer2.volume_db = -80.0
		$AudioStreamPlayer3.volume_db = -80.0
		$AudioStreamPlayer4.volume_db = -80.0
		$AudioStreamPlayer5.volume_db = -80.0
		$AudioStreamPlayer6.volume_db = -80.0
	else:
		$AudioStreamPlayer.volume_db = -16.0
		$AudioStreamPlayer2.volume_db = -16.0
		$AudioStreamPlayer3.volume_db = -16.0
		$AudioStreamPlayer4.volume_db = -16.0
		$AudioStreamPlayer5.volume_db = -16.0
		$AudioStreamPlayer6.volume_db = -16.0


func play_theme():
	$AudioStreamPlayer.play()

func play_tutorial():
	$AudioStreamPlayer6.play()

func play_garden():
	$AudioStreamPlayer2.play()

func play_arcade():
	$AudioStreamPlayer3.play()

func play_igloo():
	$AudioStreamPlayer4.play()

func play_end():
	$AudioStreamPlayer5.play()

func stop_music():
		$AudioStreamPlayer.stop()
		$AudioStreamPlayer2.stop()
		$AudioStreamPlayer3.stop()
		$AudioStreamPlayer4.stop()
		$AudioStreamPlayer5.stop()
		$AudioStreamPlayer6.stop()
