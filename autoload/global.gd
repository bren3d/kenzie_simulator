@tool
extends Node

var player_name: String = "Kenzo"
var player: Player

var active_stats: Dictionary = {
	cough = false,
	soda = false,
	pickle = false,
}

var play_wake_up_cutscene_on_ready: bool = false 
var boss_fight_active: bool = false

func make_player_camera_current() -> void:
	if player and player.camera:
		player.camera.make_current()

func reset() -> void:
	active_stats = {
	cough = false,
	soda = false,
	pickle = false,
	}
	boss_fight_active = false
