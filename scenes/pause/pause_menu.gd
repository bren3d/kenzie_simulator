@tool
class_name PauseMenu extends Control

const MAX_ALPHA: float = 0.7
const FADE_DURATION_SEC: float = 0.6 

@export var settings_menu: SettingsMenu
@export var color_rect: ColorRect
@export var button_container: Control

var active: bool = false: set = set_active, get = is_active

func _ready() -> void:
	if Engine.is_editor_hint(): return
	
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	settings_menu.request_close.connect(close)
	settings_menu.hide()
	hide()

func open() -> void:
	if visible: return
	
	set_active(true)

	tween(true)
	button_container.show()
	get_buttons()[0].grab_focus()
	get_buttons()[0].grab_click_focus()
	show()

func close() -> void:
	
	if visible and settings_menu.visible:
		settings_menu.hide()
		button_container.show()
		get_buttons()[0].grab_focus()
		return
	
	if not button_container.visible: 
		return
	
	button_container.hide()

	set_active(false)

	tween(false).tween_callback(hide)

func toggle() -> void:
	if visible:		close()
	else:			open()

func tween(to_visible: bool) -> Tween:
	var tw: Tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(color_rect, ^"color:a",  MAX_ALPHA if to_visible else 0.0, FADE_DURATION_SEC)
	return tw

func open_settings() -> void:
	settings_menu.show()
	button_container.hide()

func quit_to_main() -> void:
	close()
	active = false
	get_tree().change_scene_path(ProjectSettings.get_setting("application/run/main_scene"))

func get_buttons() -> Array[Control]:
	var buts: Array[Control]
	for but: Control in button_container.get_children():
		buts.push_back(but)
	return buts

func _input(event: InputEvent) -> void:
	if visible and event.is_action_pressed(&"pause"):
		close()
		accept_event()

func _on_resume_pressed() -> void:
	close()

func _on_settings_pressed() -> void:
	open_settings()

func _on_quit_pressed() -> void:
	quit_to_main()

func set_active(val: bool) -> void:
	active = val
	if Engine.is_editor_hint(): return
	get_tree().scene.process_mode = Node.PROCESS_MODE_DISABLED if active else Node.PROCESS_MODE_INHERIT
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if active else Input.MOUSE_MODE_CAPTURED

func is_active() -> bool:
	return active
