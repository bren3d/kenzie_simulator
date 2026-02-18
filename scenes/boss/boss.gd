extends Node3D

@export var music_stream: AudioStream
@export var player: Player
@export var boss_intro_cutscene: Cutscene
@export var kill_katie_quest: Quest
@export var cat_spawner: CatSpawner
@export var boss_katie: BossKatie

@export var cutscene_delay_sec: float = 0.7

func _ready() -> void:
	player.refill_stats()
	player.set_flashlight_enabled(false)
	
	if Global.boss_fight_active:
		start_fight()
		return
	
	Global.boss_fight_active = true
	player.input_active = false # No moving before cutscene
	
	create_tween().tween_callback(boss_intro_cutscene.play).set_delay(cutscene_delay_sec)

func start_fight() -> void:
	player.ui.show()
	Audio.play_music(music_stream)
	if not QuestHandle.active_quest == kill_katie_quest:
		QuestHandle.start_quest(kill_katie_quest)
	cat_spawner.active = true
	boss_katie.set_state(&"charge")
