extends Node3D

@export var music_stream: AudioStream
@export var player: Player
@export var kill_katie_quest: Quest


func _ready() -> void:
	
	Audio.play_music(music_stream)
	
	player.set_flashlight_enabled(false)
	Global.boss_fight_active = true
	QuestHandle.start_quest(kill_katie_quest)
