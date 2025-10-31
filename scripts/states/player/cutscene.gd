@tool
extends PlayerState

func _init() -> void:
	name = &"Cutscene"

func enter() -> void:
	player.pause_timers()
	player.set_input_active(false)
	player.set_interaction_active(false)
	player.velocity *= Vector3(0.0, 1.0, 0.0)

func exit() -> void:
	player.set_input_active(true)
	player.set_interaction_active(true)
	player.unpause_timers()
	player.camera.make_current()
