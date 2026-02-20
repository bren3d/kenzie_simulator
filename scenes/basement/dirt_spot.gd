@tool
extends Node3D

signal sweeping_finished

@export var mesh_instance: MeshInstance3D
@export var task_updater: TaskUpdater
@export var waypoint: QuestWaypoint
@export var player: AudioStreamPlayer3D

@export var broom: Node3D

@export var broom_start_position: Node3D
@export var broom_lowered_position: Node3D

@export var sweep_audio_stream: AudioStream

@export var broom_starting_rotation_deg: Vector3 = Vector3(-90.0, -30.0, 0.0)

@export_range(0.0, 90.0, 1.0, "radians_as_degrees") 
var max_rotation_angle: float = PI/6.0

@export var lower_duration_sec: float = 0.7

@export_range(1.0, 20.0, 1.0, "or_greater") 
var sweep_cycle_count: int = 10

@export var is_skippable: bool = true

var active: bool = false
var tw: Tween

func _ready() -> void:
	set_process_input(false)
	if Engine.is_editor_hint(): return
	task_updater.quest.task_updated.connect(_on_task_updated)

func _on_task_updated(t: Task) -> void:
	if t.task_name == task_updater.task_name and t.is_started():
		task_updater.quest.task_updated.disconnect(_on_task_updated)
		get_meta(&"Interactable").interaction_started.connect(_on_interaction_started, CONNECT_ONE_SHOT)
		get_meta(&"Interactable").disabled = false

func _on_interaction_started(interactor: Object) -> void:
	Global.player.set_state("Cutscene")
	active = true
	waypoint.hide()
	get_meta(&"Interactable").disabled = true
	play_animation()

func play_animation() -> void:
	broom.global_position = broom_start_position.global_position
	broom.rotation_degrees = broom_starting_rotation_deg
	broom.show()
	
	set_process_input(is_skippable)
	
	tw = create_tween()
	tw.tween_property(broom, ^"global_position", broom_lowered_position.global_position, lower_duration_sec)
	tw.tween_callback(player.play)
	tw.finished.connect(tween_sweep, CONNECT_ONE_SHOT)

func tween_sweep() -> void:
	var sweeping_duration_sec: float = sweep_audio_stream.get_length() / 2.0 / sweep_cycle_count
	tw = create_tween().set_loops(sweep_cycle_count)
	tw.tween_property(broom, ^"rotation:x", deg_to_rad(broom_starting_rotation_deg.x) + max_rotation_angle, sweeping_duration_sec)
	tw.tween_property(broom, ^"rotation:x", deg_to_rad(broom_starting_rotation_deg.x) - max_rotation_angle, sweeping_duration_sec)
	tw.finished.connect(_on_sweeping_finished, CONNECT_ONE_SHOT)


func _on_sweeping_finished() -> void:
	active = false
	set_process_input(false)
	task_updater.update_task()
	player.stop()
	
	broom.hide()
	hide()
	Global.player.set_state("Moving")
	
	sweeping_finished.emit()


func skip() -> void:
	if tw:
		tw.kill()
	Audio.sfx_stream.stop()
	_on_sweeping_finished()

func _input(event: InputEvent) -> void:
	if active and event.is_action_pressed(&"skip"):
		skip()
		get_viewport().set_input_as_handled()
		get_tree().root.set_input_as_handled()
