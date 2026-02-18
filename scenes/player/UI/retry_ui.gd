@tool
class_name RetryUI extends CanvasLayer

@export var rect: TextureRect
@export var you_died_label: Label
@export var death_message: Label
@export var retry_button: Button
@export var quit_button: Button
@export var button_h_box: HBoxContainer

@export var rect_tween_params: TweenParameters
@export var rect_fade_sec: float = 1.2

@export var message_tween_params: TweenParameters
@export var message_fade_sec: float = 0.4

@export var but_tween_params: TweenParameters
@export var but_fade_sec: float = 0.3


func _ready() -> void:
	if Engine.is_editor_hint(): return
	close()

func open(death_msg: String = "") -> void:
	show()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	death_message.text = death_msg
	rect_tween_params.create_tween_bound(self).tween_property(rect, ^"modulate:a", 1.0, rect_fade_sec)
	
	# Subtween
	var but_tw: Tween = but_tween_params.create_tween_bound(self)
	but_tw.tween_callback(retry_button.show)
	but_tw.tween_callback(quit_button.show)
	but_tw.tween_property(button_h_box, ^"modulate:a", 1.0, but_fade_sec)
	but_tw.tween_callback(retry_button.grab_focus)
	
	var msg_tw: Tween = message_tween_params.create_tween_bound(self)
	msg_tw.tween_interval(rect_fade_sec - message_fade_sec)
	msg_tw.tween_property(you_died_label, ^"modulate:a", 1.0, message_fade_sec)
	msg_tw.tween_property(death_message, ^"modulate:a", 1.0, message_fade_sec)
	msg_tw.tween_subtween(but_tw)

func close() -> void:
	rect.modulate.a = 0.0
	you_died_label.modulate.a = 0.0
	death_message.modulate.a = 0.0
	button_h_box.modulate.a = 0.0
	retry_button.hide()
	quit_button.hide()
	hide()

func _on_retry_button_pressed() -> void:
	if Global.boss_fight_active:
		get_tree().reload_scene()
	else:
		Global.player.set_state("Moving")

func _on_quit_button_pressed() -> void:
	get_tree().quit()
