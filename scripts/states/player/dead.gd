@tool
extends PlayerState

@export var camera_action: CameraAction

func _init() -> void:
	name = &"Dead"

func enter() -> void:
	#lock_state.emit(true)
	player.can_cough = false
	camera_action.focus()

func exit() -> void:
	player.can_cough = true
	camera_action.restore_camera()
