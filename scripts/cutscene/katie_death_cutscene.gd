@tool
extends Cutscene

@export var camera_shaker: CameraShaker
@export var death_scream_player: AudioStreamPlayer
@export var end: PackedScene

func _on_play() -> void:
	if Engine.is_editor_hint(): return
	Global.player.set_state(&"Moving")
	death_scream_player.play()
	camera_shaker.shake_camera()
	create_tween().tween_callback(get_tree().change_scene_packed.bind(end)).set_delay(death_scream_player.stream.get_length())
