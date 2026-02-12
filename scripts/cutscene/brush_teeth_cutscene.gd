@tool
extends Cutscene

@export var interactable: Interactable
@export var quest_waypoint: QuestWaypoint
@export var blackout_rect: ColorRect
@export var fade_duration: float = 0.5
@export var teeth_brushing_sound: AudioStream
@export var gargle_sound: AudioStream

@export var brushing_quest: Quest
@export var task_name: String

@export var play_brushing_sound: bool = true

var tw: Tween

func _ready() -> void:
	set_process_input(false)

func _on_play() -> void:
	if Engine.is_editor_hint(): return
	interactable.disabled = true
	quest_waypoint.hide()
	
	var player: Player = Global.player
	player.set_state.call_deferred("Cutscene")
	
	tw = create_tween()
	tw.tween_property(blackout_rect, ^"color:a", 1.0, fade_duration)
	tw.tween_callback(set_process_input.bind(true))
	
	if play_brushing_sound:
		tw.tween_callback(Audio.play_sfx.bind(teeth_brushing_sound))
		tw.tween_interval(teeth_brushing_sound.get_length())
	
	
	tw.tween_callback(Audio.play_sfx.bind(gargle_sound))
	tw.tween_interval(gargle_sound.get_length())
	
	tw.finished.connect(_on_tween_finished)

func _on_tween_finished() -> void:
	tw = create_tween()
	tw.tween_property(blackout_rect, ^"color:a", 0.0, fade_duration)
	
	tw.tween_callback(brushing_quest.update_task_status.bind(task_name, Task.STATUS_COMPLETED))
	
	tw.tween_callback(finish)

func skip() -> void:
	if tw: 
		tw.kill()
	Audio.sfx_stream.stop()
	_on_tween_finished()

#func _input(event: InputEvent) -> void:
	#if event.is_action_pressed(&"ui_cancel") and tw:
		#get_viewport().set_input_as_handled()
		#tw.kill()
		#Audio.sfx_stream.stop()
		#_on_tween_finished()
