@tool
class_name PauseMenu extends Control

const MAX_ALPHA: float = 0.3
#const SETTINGS_MENU_SCENE: PackedScene = preload("res://scenes/menus/settings/settings_menu.tscn")
const FADE_DURATION_SEC: float = 0.6 

@export var settings_menu: SettingsMenu
@export var color_rect: ColorRect
@export var button_container: Control


func _ready() -> void:
	if Engine.is_editor_hint(): return
	
	get_parent().tree_exiting.connect(queue_free)
	self.reparent.call_deferred(get_tree().root)
	
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	settings_menu.request_close.connect(close)
	settings_menu.hide()
	hide()

func open() -> void:
	if visible: return
	get_tree().scene.process_mode = Node.PROCESS_MODE_DISABLED
	
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	tween(true)
	button_container.show()
	get_buttons()[0].grab_focus()
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
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	get_tree().scene.process_mode = Node.PROCESS_MODE_INHERIT
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
	get_tree().scene.process_mode = Node.PROCESS_MODE_DISABLED
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
