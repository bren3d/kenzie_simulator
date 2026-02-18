@tool
extends PlayerState

func _init() -> void:
	name = &"Cursor"

#func enter() -> void:
	#get_tree().set(&"mouse_mode", Input.MOUSE_MODE_VISIBLE)

#func update_physics_process(delta: float) -> void:
	#pass

#func on_input(event: InputEvent) -> void:
	#if not event.is_pressed(): return
	#
	#if event is InputEventMouseButton and event.button_mask&MOUSE_BUTTON_MASK_LEFT:
		#transition_requested.emit(blackboard.previous_state.name)
		#get_viewport().set_input_as_handled()
