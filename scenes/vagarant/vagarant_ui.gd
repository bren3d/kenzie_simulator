@tool
extends CanvasLayer

const MAX_COLOR_RECT_ALPHA: float = 1.0
const FADE_IN_DURATION_SEC: float = 1.2
const VICTORY_SCREEN_DURATION_SEC: float = 4.2

signal play_pressed
signal quit_pressed

signal menu_shown

@export var targeting_handle: TargetingHandle
@export var event_handle: VagarantEventHandle
@export var score_label: Label
@export var victory_label: Label
@export var color_rect: ColorRect
@export var menu: Control

@export var play_button: Button
@export var quit_button: Button


func reset_ui() -> void:
	color_rect.color.a = 0.0
	victory_label.modulate.a = 0.0
	score_label.hide()

func play_victory_screen() -> void:
	var tw: Tween = create_tween().set_parallel()
	tw.tween_property(color_rect, ^"color:a", MAX_COLOR_RECT_ALPHA, FADE_IN_DURATION_SEC)
	tw.tween_property(victory_label, ^"modulate:a", 1.0, FADE_IN_DURATION_SEC)
	tw.tween_callback(show_menu).set_delay(VICTORY_SCREEN_DURATION_SEC)

func show_menu() -> void:
	Input.set_mouse_mode.call_deferred(Input.MOUSE_MODE_VISIBLE)
	#Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	menu.show()
	reset_ui()
	play_button.disabled = false
	quit_button.disabled = false
	menu_shown.emit()
	play_button.grab_focus()

func hide_menu() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	play_button.disabled = true
	quit_button.disabled = true
	menu.hide()

func _on_round_ended() -> void:
	score_label.text = "%d VS 0" % event_handle.round_count

func _on_round_started() -> void:
	score_label.show()

func _on_match_ended() -> void:
	score_label.hide()
	score_label.text = "0 VS 0"
	play_victory_screen()

func _on_play_button_pressed() -> void:
	play_pressed.emit()
	hide_menu()

func _on_quit_button_pressed() -> void:
	quit_pressed.emit()

func _unhandled_input(event: InputEvent) -> void:
	if menu.visible and not play_button.has_focus() and not quit_button.has_focus():
		play_button.grab_focus()
		get_viewport().set_input_as_handled()
