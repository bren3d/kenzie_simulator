@tool
extends Cutscene

const DEFAULT_KATIE_LOCATION: Vector3 = Vector3()
const DISTANCE_OFFSET: float = 1.275/2.0

@export var katie: BossKatie
@export var katie_focus: Node3D
@export var rotation_base: Node3D
@export var sound_player: AudioStreamPlayer3D

@export var rotation_time_sec: float = 0.75
@export var lunge_delay_sec: float = 0.5
@export var lunge_time_sec: float = 0.3

func _on_play() -> void:
	if Engine.is_editor_hint(): return
	
	rotation_base.look_at(Global.player.global_position, rotation_base.global_basis.y, true)
	var target_transform: Transform3D = rotation_base.global_transform
	rotation_base.rotation = Vector3.ZERO
	var target_position: Vector3 = Global.player.camera.global_position.move_toward(katie.global_position, DISTANCE_OFFSET)
	
	create_tween().tween_property(katie, ^"global_transform", target_transform, rotation_time_sec/2.0)
	
	var tw: Tween = create_tween()
	tw.tween_callback(Global.player.camera_controller.look_toward.bind(katie_focus.global_position, rotation_time_sec))
	tw.tween_interval(rotation_time_sec)
	tw.tween_interval(lunge_delay_sec)
	tw.tween_callback(sound_player.play)
	tw.tween_property(katie, ^"global_position", target_position, lunge_time_sec)
	tw.tween_callback(katie.hide)
	tw.tween_callback(hit_player)


func hit_player() -> void:
	
	Global.player.hit()
	
	if Global.player.is_dead():
		return
	
	katie.set_state(&"charge")
	
	katie.show()
	
	finish()
