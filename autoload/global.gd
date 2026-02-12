@tool
extends Node

var player_name: String = "Kenzo"
var player: Player
var quest_handle: Node

func make_player_camera_current() -> void:
	if player and player.camera:
		player.camera.make_current()
