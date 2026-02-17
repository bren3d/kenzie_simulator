@tool
extends Cutscene

@export var trigger_area: Area3D

@export var brush_teeth_quest: Quest

@export var alex: NPC
@export var sting: AudioStream

@export var dialogue: DialogueResource
@export var dialogue_title: String = "intro"

@export var alex_hidden_marker: Node3D
@export var start_marker: Node3D
@export var lean_marker: Node3D
@export var cam_action: CameraAction

@export var lean_duration: float = 0.15


func _ready() -> void:
	if Engine.is_editor_hint(): return
	alex.visible = false
	alex.global_transform = alex_hidden_marker.global_transform
	brush_teeth_quest.task_updated.connect(_on_task_updated)

func _on_task_updated(t: Task) -> void:
	if t.task_name != "Teeth" or not t.is_completed(): return
	brush_teeth_quest.task_updated.disconnect(_on_task_updated)
	setup_cutscene()

func setup_cutscene() -> void:
	trigger_area.set_monitoring.call_deferred(true)
	alex.global_transform = start_marker.global_transform
	trigger_area.body_entered.connect(play.unbind(1))

func _on_play() -> void:
	if Engine.is_editor_hint(): return
	trigger_area.set_monitoring.call_deferred(false)
	
	var player: Player = Global.player
	
	alex.show()
	
	Audio.play_sfx(sting)
	var tw: Tween = create_tween()
	tw.tween_callback(cam_action.focus)
	tw.tween_property(alex, ^"global_transform", lean_marker.global_transform, lean_duration)
	tw.tween_callback(DialogueManager.show_dialogue_balloon.bind(dialogue, dialogue_title))
	
	await DialogueManager.dialogue_ended
	
	tw = create_tween()
	tw.tween_property(alex, ^"global_transform", start_marker.global_transform, lean_duration)
	tw.tween_callback(alex.hide)
	tw.tween_callback(alex.set_global_transform.bind(alex_hidden_marker.global_transform))
	tw.tween_callback(cam_action.release_focus)
	
	# Advance to light & list tasks
	tw.tween_callback(brush_teeth_quest.advance_task)
	
	tw.tween_interval(cam_action.tween_duration_sec)
	
	tw.tween_callback(finish)
