@tool
extends CatState

#signal transition_requested(new_state: String)
#signal lock_state(set_locked: bool)

#var blackboard: Dictionary

func _init() -> void:
	name = &"CatState"

func enter() -> void:
	pass

func exit() -> void:
	pass

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
