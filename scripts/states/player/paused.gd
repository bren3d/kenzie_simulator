@tool
extends PlayerState

func _init() -> void:
	name = &"Paused"

func enter() -> void:
	player.pause_menu.show()
	player.pause_menu.visibility_changed.connect(player.set_state.bind(blackboard.previous_state.name), CONNECT_ONE_SHOT)
