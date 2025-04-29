@tool
class_name State extends Node

signal transition_requested(new_state: String)
signal lock_state(set_locked: bool)

var blackboard: Dictionary: set = set_blackboard

func enter() -> void:
	pass

func exit() -> void:
	pass

## Overwrite to set parent node to variable.
func set_host(host: Node) -> void:
	pass

func set_blackboard(val: Dictionary) -> void:
	blackboard = val

func update_process(delta: float) -> void:
	pass

func update_physics_process(delta: float) -> void:
	pass

func on_input(event: InputEvent) -> void:
	pass

func on_unhandled_input(event: InputEvent) -> void:
	pass

func on_mouse_entered() -> void:
	pass

func on_mouse_exited() -> void:
	pass
