extends Node3D

@onready var mp3: AudioStreamPlayer = $AudioStreamPlayer

var playlist: AudioStreamPlaylist
var current_track := 0

func _ready() -> void:
	playlist = mp3.stream as AudioStreamPlaylist
	play_track(current_track)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("skip_track"):
		skip_next()

func play_track(index: int) -> void:
	current_track = wrapi(index, 0, playlist.stream_count)
	mp3.stream = playlist.get_list_stream(current_track)
	mp3.play()

func skip_next() -> void:
	play_track(current_track + 1)
