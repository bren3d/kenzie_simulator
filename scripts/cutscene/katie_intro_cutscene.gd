@tool
extends Cutscene

@export var katie: Katie
@export var door: Door
@export var dialogue: DialogueResource
@export var dialogue_title: String = "intro"
@export var cam_action: CameraAction

@export var sting: AudioStream
@export var creepy_laugh: AudioStream
@export var giggle_echo: AudioStream
@export var breathing: AudioStream

@export var start: Node3D
@export var breathing_player: AudioStreamPlayer3D
@export var giggle_player: AudioStreamPlayer3D

func _on_play() -> void:
	if Engine.is_editor_hint(): return
	
	giggle_player.stream = creepy_laugh
	
	katie.play(&"idle")
	katie.set_texture(katie.default_texture)
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
	tw.tween_callback(breathing_player.play)
	tw.tween_callback(DialogueManager.show_dialogue_balloon.bind(dialogue, dialogue_title, [{"audio_player": giggle_player}]))
	
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended.unbind(1), CONNECT_ONE_SHOT)
	

func _on_dialogue_ended() -> void:
	Audio.pause_music(true)
	door.set_open(false)
	door.set_locked(true)
	cam_action.release_focus()
	giggle_player.stream = giggle_echo
	
	var tw: Tween = create_tween()
	tw.tween_interval(door.tween_duration_sec)
	tw.tween_callback(giggle_player.play)
	tw.tween_callback(katie.hide)
	tw.tween_callback(breathing_player.stop)
	tw.tween_callback(finish)
	
	#tw.tween_callback(cam_action.release_focus)

func _unhandled_input(event: InputEvent) -> void:
	if not is_active and event.is_pressed() and event is InputEventKey and event.keycode == KEY_L:
		play()
