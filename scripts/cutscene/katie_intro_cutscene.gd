@tool
extends Cutscene

@export var katie: Node3D
@export var door: Door
@export var dialogue: DialogueResource
@export var dialogue_title: String = "intro"
@export var cam_action: CameraAction

@export var sting: AudioStream
@export var creepy_laugh: AudioStream
@export var giggle_echo: AudioStream
@export var breathing: AudioStream

@export var start: Node3D

func _on_play() -> void:
	if Engine.is_editor_hint(): return
	
	katie.show()
	katie.global_position = start.global_position
	#katie.look_at(Global.player.global_position)
	
	door.set_locked(false)
	door.set_open(true)
	
	var tw: Tween = create_tween()
	tw.tween_interval(door.tween_duration_sec/2.0)
	tw.tween_callback(Audio.play_sfx.bind(sting))
	tw.tween_interval(door.tween_duration_sec/2.0)
	tw.tween_callback(cam_action.focus)
	tw.tween_callback(Audio.play_music.bind(breathing))
	tw.tween_callback(DialogueManager.show_dialogue_balloon.bind(dialogue, dialogue_title, [{"creepy_laugh": creepy_laugh}]))
	
	await DialogueManager.dialogue_ended
	
	Audio.pause_music(true)
	door.set_open(false)
	door.set_locked(true)
	cam_action.release_focus()
	tw = create_tween()
	tw.tween_interval(door.tween_duration_sec)
	tw.tween_callback(Audio.play_sfx.bind(giggle_echo))
	tw.tween_callback(katie.hide)
	tw.tween_callback(Global.player.set_state.bind("Moving"))
	#tw.tween_callback(cam_action.release_focus)
