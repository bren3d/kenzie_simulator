@tool
extends PlayerState

@export var camera_action: CameraAction
@export var retry_ui: RetryUI

func _init() -> void:
	name = &"Dead"

func enter() -> void:
	#lock_state.emit(true)
	player.pause_timers()
	camera_action.focus()
	
	player.ui.hide()
	
	var tw: Tween = create_tween()
	tw.tween_callback(player.dead.emit).set_delay(camera_action.tween_duration_sec)
	tw.tween_callback(retry_ui.open.bind(Global.player.death_message))

func exit() -> void:
	camera_action.restore_camera()
	retry_ui.close()
	player.ui.show()
	player.refill_stats()
	player.unpause_timers()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
