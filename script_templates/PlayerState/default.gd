@tool
extends PlayerState

#signal transition_requested(new_state: String)
#signal lock_state(set_locked: bool)

#var blackboard: Dictionary

func _init() -> void:
	name = &"PlayerState"

func enter() -> void:
	pass

func exit() -> void:
	pass

func update_process(delta: float) -> void:
	pass

func update_physics_process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	player.velocity += player.get_gravity() * delta * int(not player.is_on_floor()) 
	player.move_and_slide()


func on_input(event: InputEvent) -> void:
	pass

func on_unhandled_input(event: InputEvent) -> void:
	pass

func on_mouse_entered() -> void:
	pass

func on_mouse_exited() -> void:
	pass
