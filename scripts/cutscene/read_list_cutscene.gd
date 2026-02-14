@tool
extends Cutscene

@export var teeth_quest: Quest
@export var list_task_name: String

@export var list_quest: Quest

@export var list: Node3D
@export var list_interactable: Interactable
@export var list_mesh_material: StandardMaterial3D

@export var paper_pickup_audio: AudioStream
@export var paper_stash_audio: AudioStream

@export var list_dialogue: DialogueResource

@export var list_pickup_distance: float = 0.75
@export var list_pickup_duration_sec: float = 0.35
@export var quest_start_delay_sec: float = 0.75


func _ready() -> void:
	if Engine.is_editor_hint(): return
	list.hide()
	list_interactable.disabled = true
	teeth_quest.task_updated.connect(_on_task_updated)

func _on_task_updated(t: Task) -> void:
	if list_task_name != t.task_name or not t.is_started(): return
	list.show()
	list_interactable.disabled = false
	teeth_quest.task_updated.disconnect(_on_task_updated)
	list_interactable.interaction_started.connect(play.unbind(1), CONNECT_ONE_SHOT)

func _on_play() -> void:
	if Engine.is_editor_hint(): return
	
	list_interactable.disabled = true
	list_mesh_material.no_depth_test = true
	
	while not Global.player.is_on_floor():
		await get_tree().physics_frame
	
	teeth_quest.update_task_status("list", Task.STATUS_COMPLETED)
	
	var cam: Camera3D = get_viewport().get_camera_3d()
	var target_transform: Transform3D = Transform3D(cam.global_basis, cam.global_position - cam.global_basis.z * list_pickup_distance)
	var tw: Tween = create_tween()
	tw.tween_callback(Audio.play_sfx.bind(paper_pickup_audio))
	tw.tween_property(list, ^"global_transform", target_transform, list_pickup_duration_sec)
	tw.tween_callback(DialogueManager.show_dialogue_balloon.bind(list_dialogue))
	
	await DialogueManager.dialogue_ended
	
	Audio.play_sfx(paper_stash_audio)
	
	list.hide()
	Global.player.set_state("Moving")
	
	QuestHandle.start_quest(list_quest)
	
