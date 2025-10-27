@tool
extends Cutscene

@export_range(0.0, 3.0, 0.1, "suffix:s") 
var wake_up_delay: float = 1.5

@export var wake_up_dialogue: DialogueResource
@export var camera_target: Node3D
@export var camera_action: CameraAction

func _on_play() -> void:
	if Engine.is_editor_hint(): return
	print("Playing...")
	
	Audio.pause_music(true)
	
	var player: Player = get_tree().get_first_node_in_group(&"Player")
	assert(player)
	var player_fov: float = player.camera.fov
	camera_action.camera.make_current.call_deferred()
	
	await get_tree().create_timer(wake_up_delay).timeout
	
	camera_action.interpolate_camera(camera_action.global_transform, camera_target, player_fov, player_fov)
	await camera_action._interpolation_finished
	
	DialogueManager.show_dialogue_balloon(wake_up_dialogue,)
	await DialogueManager.dialogue_ended
	
	camera_action.interpolate_camera(camera_target.global_transform, player.camera, player_fov, player_fov)
	await camera_action._interpolation_finished
	
	# TODO Update Quest
	
	player.set_state("Moving")
	
