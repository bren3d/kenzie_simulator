@tool
extends Cutscene

@export var door: Door

func play() -> void:
	door.set_locked(true)
	is_active = true
	started.emit()
	_on_play()
	set_process_input(true)

func _on_play() -> void:
	if Engine.is_editor_hint(): return
	Global.player.show_message("Press C to cough", 0.0)

func enable_cough() -> void:
	Global.active_stats.cough = true
	Global.player.cough_stat.disabled = false
	Global.player.cough_stat.paused = false
	door.set_locked(false)
	Global.player.hide_message()
	set_process_input(false)
	finish()
	create_tween().tween_callback(Global.player.show_message.bind("Press E to interact", 2.5))\
		.set_delay(Player.MESSAGE_FADE_IN_OUT_DURATION_SEC)
	

func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"cough"):
		enable_cough()
