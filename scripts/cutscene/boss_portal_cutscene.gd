@tool
extends Cutscene

# How soon before the end of the sting it transitions to the next scene.
const TRANSITION_EARLY_START_SEC: float = 3.0

@export var door: Door
@export var boss_scene: PackedScene
@export var boss_portal_camera_action: CameraAction
@export var katie: Katie
@export var boss_portal_spot_light: SpotLight3D

@export var katie_target: Node3D
@export var katie_tween_duration_sec: float = 0.24
@export var blackout_delay_sec: float = 0.1

@export var sting: AudioStreamWAV

func _on_play() -> void:
	if Engine.is_editor_hint(): return
	
	katie.set_texture(katie.bloody_texture)
	door.set_locked(false)
	door.slam_door_on_close = true
	
	var flashlight: SpotLight3D = Global.player.flashlight.duplicate()
	flashlight.hide()
	boss_portal_camera_action.camera.add_child(flashlight)
	Global.player.set_flashlight_enabled(false)
	flashlight.show()
	boss_portal_camera_action.focus()
	
	var tw: Tween = create_tween()
	tw.tween_interval(boss_portal_camera_action.tween_duration_sec)
	tw.tween_callback(door.set_open.bind(false))
	tw.tween_interval(door.slam_duration_sec)
	tw.tween_callback(katie.show)
	tw.tween_property(katie, ^"global_position", katie_target.global_position, katie_tween_duration_sec)
	tw.tween_callback(Audio.play_sfx.bind(sting))
	tw.tween_interval(blackout_delay_sec)
	tw.tween_callback(flashlight.hide)
	tw.tween_callback(boss_portal_spot_light.hide)
	tw.tween_interval(sting.get_length() - blackout_delay_sec - TRANSITION_EARLY_START_SEC)
	tw.tween_callback(get_tree().change_scene_packed.bind(boss_scene))
	
