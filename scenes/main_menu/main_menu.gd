@tool
extends Control

@export var dream: Node3D
@export var camera_3d: Camera3D

@export var sub_viewport: SubViewport
@export var menu: Control
@export var settings_menu: SettingsMenu
@export var play_button: Button
@export var tween_duration_sec: float = 0.8

var is_playing: bool = false

func _ready() -> void:
	if Engine.is_editor_hint(): return
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	play_button.grab_focus()

func play() -> void:
	menu.hide()
	var tw: Tween = create_tween()
	tw.tween_property(camera_3d, ^"rotation", Vector3.ZERO, tween_duration_sec)
	tw.tween_callback(set.bind(&"is_playing", true))
	tw.tween_callback(dream.play)

func _on_play_button_pressed() -> void:
	play()

func _on_settings_button_pressed() -> void:
	menu.hide()
	settings_menu.open()

func _on_settings_request_close() -> void:
	settings_menu.close()
	menu.show()

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _input(event: InputEvent) -> void:
	if is_playing:
		sub_viewport.push_input(event)

func _gui_input(event: InputEvent) -> void:
	if is_playing:
		sub_viewport.push_input(event)
