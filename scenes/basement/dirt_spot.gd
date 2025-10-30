@tool
extends Node3D

signal sweeping_finished

@export var mesh_instance: MeshInstance3D
@export var task_updater: TaskUpdater
@export var waypoint: QuestWaypoint

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

func _ready() -> void:
	if Engine.is_editor_hint(): return
	task_updater.quest.task_updated.connect(_on_task_updated)

func _on_task_updated(t: Task) -> void:
	if t.task_name == task_updater.task_name and t.is_started():
		task_updater.quest.task_updated.disconnect(_on_task_updated)
		get_meta(&"Interactable").interaction_started.connect(_on_interaction_started, CONNECT_ONE_SHOT)
		get_meta(&"Interactable").disabled = false

func _on_interaction_started(interactor: Object) -> void:
	Global.player.set_state.call_deferred("Cutscene")
	waypoint.hide()
	get_meta(&"Interactable").disabled = true
	play_sweeping_animation()

func play_sweeping_animation() -> void:
	broom.global_position = broom_start_position.global_position
	broom.rotation_degrees = broom_starting_rotation_deg
	broom.show()
	
	var tw: Tween = create_tween()
	tw.tween_property(broom, ^"global_position", broom_lowered_position.global_position, lower_duration_sec)
	tw.tween_callback(Audio.play_sfx.bind(sweep_audio_stream))
	
	await tw.finished
	
	var sweeping_duration_sec: float = sweep_audio_stream.get_length() / 2.0 / sweep_cycle_count
	tw = create_tween().set_loops(sweep_cycle_count)
	tw.tween_property(broom, ^"rotation:x", deg_to_rad(broom_starting_rotation_deg.x) + max_rotation_angle, sweeping_duration_sec)
	tw.tween_property(broom, ^"rotation:x", deg_to_rad(broom_starting_rotation_deg.x) - max_rotation_angle, sweeping_duration_sec)
	
	await tw.finished
	
	broom.hide()
	task_updater.update_task()
	hide()
	Global.player.set_state("Moving")
	#tw.tween_callback(broom.hide)
	#tw.tween_callback(task_updater.update_task)
	#tw.tween_callback(hide)
	
