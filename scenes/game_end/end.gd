@tool
extends Control

@export var replay_button: Button
@export var quit_button: Button

func _ready() -> void:
	if Engine.is_editor_hint(): return
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	replay_button.grab_focus()

func _on_replay_button_pressed() -> void:
	get_tree().reset()

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _gui_input(event: InputEvent) -> void:
	if replay_button.has_focus() or quit_button.has_focus(): return
	replay_button.grab_focus()
