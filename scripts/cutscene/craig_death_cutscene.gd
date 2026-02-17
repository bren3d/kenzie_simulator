@tool
extends Cutscene

@export var deer: Node3D
@export var deer_target_location: Marker3D

@export var lights: Node3D
@export var spotlight: SpotLight3D

@export var blood_splat: Array[Node3D]

@export var cam: Camera3D
@export var katie: Katie
@export var door: Door
@export var door2: Door


@export var katie_start_location: Marker3D
@export var katie_target_location: Marker3D

@export_range(0.1, 2.0, 0.05, "suffix:s") 
var katie_movement_duration_sec: float = 0.5

#@export_group("Interactable")
@export var dialogue_action: DialogueAction
@export var dialogue_section_title: String = "dead"

#@export_group("Audio")
@export var audio_stream: AudioStreamPlayer3D
@export var sfx_whinny: AudioStream
@export var sfx_gore_splat: AudioStream
@export var sfx_screech: AudioStream
@export var music: AudioStream

@export var initial_delay_sec: float = 0.5
@export var gore_delay_sec: float = 0.3

@export var dialogue_delay_sec: float = 0.4
@export var dialogue_resource: DialogueResource

@export var fov_tween_duration_sec: float = 0.4

@export var quest: Quest

@export var boss_scene: PackedScene

func _ready() -> void:
	if Engine.is_editor_hint(): return
	katie.hide()

func _on_play() -> void:
	if Engine.is_editor_hint(): return
	lights.hide()
	Global.player.set_flashlight_active(false)
	deer.global_transform = deer_target_location.global_transform
	for node in blood_splat:
		node.show()
	cam.make_current()
	
	door.locked = false
	door.mute_sounds = true
	door2.mute_sounds = true
	door.set_open(true)
	door.mute_sounds = false
	door2.mute_sounds = false
	
	Global.player.global_position = cam.global_position * Vector3(1.0, 0.0, 1.0)
	Global.player.global_rotation.y = cam.global_rotation.y
	
	dialogue_action.section_title = dialogue_section_title
	
	var tw: Tween = create_tween()
	
	tw.tween_interval(initial_delay_sec)
	audio_stream.stream = sfx_whinny
	tw.tween_callback(audio_stream.play)
	
	tw.tween_interval(sfx_whinny.get_length() + gore_delay_sec)
	tw.tween_callback(audio_stream.set_stream.bind(sfx_gore_splat))
	tw.tween_callback(audio_stream.play)
	
	tw.tween_interval(sfx_gore_splat.get_length())
	tw.tween_callback(audio_stream.set_stream.bind(sfx_screech))
	tw.tween_callback(audio_stream.play)
	
	tw.tween_interval(sfx_screech.get_length() - katie_movement_duration_sec)
	tw.tween_callback(play_katie_escape)


func play_katie_escape() -> void:
	katie.show()
	katie.play(&"crabwalk")
	katie.set_texture(katie.bloody_texture)
	
	door.slam_door_on_close = true
	door2.slam_door_on_close = true
	
	var tw: Tween = create_tween()
	#tw.tween_callback(lights.show)
	tw.tween_callback(Audio.play_music.bind(music))
	tw.tween_callback(spotlight.show)
	
	tw.tween_property(katie, ^"global_position", katie_target_location.global_position, katie_movement_duration_sec).from(katie_start_location.global_position)
	tw.tween_callback(door.set_open.bind(false))
	tw.tween_callback(door.set.bind(&"slam_door_on_close", false))
	tw.tween_callback(door2.set.bind(&"slam_door_on_close", false))
	tw.tween_callback(katie.hide)
	tw.tween_property(cam, ^"fov", Global.player.camera.fov, fov_tween_duration_sec)
	
	#TODO CAMERA FOLLOW
	#TODO SPOOKY MUSIC
	
	#tw.tween_interval(dialogue_delay_sec)
	#tw.tween_callback(DialogueManager.show_dialogue_balloon.bind(dialogue_resource))
	
	tw.tween_callback(QuestHandle.start_quest.bind(quest))
	tw.tween_callback(finish)
	tw.tween_callback(spotlight.hide)
	tw.tween_callback(Global.player.set_flashlight_enabled.bind(true))
	tw.tween_callback(Global.player.set_flashlight_active.bind(true))
