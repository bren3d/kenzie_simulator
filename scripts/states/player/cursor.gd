@tool
extends PlayerState

func _init() -> void:
	name = &"Cursor"

func enter() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE 

func exit() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func update_physics_process(delta: float) -> void:
	pass

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed() and event.keycode == KEY_ESCAPE:
		transition_requested.emit(blackboard.previous_state.name if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE else name)
		get_viewport().set_input_as_handled()
