@tool
extends Cutscene

@export var tv_cam: Camera3D
@export var dvd_interactable: Interactable
@export var quest: Quest
@export var task: Task
@export var mouse_dvd: MeshInstance3D

@export var stream: VideoStreamPlayer

func _ready() -> void:
	stream.visible = false
	dvd_interactable.disabled = true
	mouse_dvd.hide()
	quest.started.connect(dvd_interactable.set_disabled.bind(false), CONNECT_ONE_SHOT)
	quest.started.connect(mouse_dvd.show, CONNECT_ONE_SHOT)
	stream.finished.connect(quest.update_task_status.bind(task.task_name, Task.STATUS_COMPLETED), CONNECT_ONE_SHOT)

func _on_play() -> void:
	if Engine.is_editor_hint(): return
	dvd_interactable.disabled = true
	tv_cam.make_current()
	
	stream.visible = true
	stream.play()
	stream.finished.connect(_on_stream_finished, CONNECT_ONE_SHOT)

func _on_stream_finished() -> void:
	Global.player.make_camera_current()
	Global.player.set_state("Moving")
	dvd_interactable.disabled = false
	stream.visible = false

#func tween_camera(start_camera: Camera3D, end_camera: Camera3D) -> void:
	#pass
