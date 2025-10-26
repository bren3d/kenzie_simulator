@tool
extends PlayerState

#signal transition_requested(new_state: String)
#signal lock_state(set_locked: bool)

#var blackboard: Dictionary

func _init() -> void:
	name = &"Cutscene"

func enter() -> void:
	#lock_state.emit(true)
	player.set_input_active(false)

func exit() -> void:
	player.set_input_active(true)
	player.camera.make_current()
