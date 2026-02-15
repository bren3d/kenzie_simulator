extends Node3D

@export var music_stream: AudioStream

func _ready() -> void:
	Audio.play_music(music_stream)
