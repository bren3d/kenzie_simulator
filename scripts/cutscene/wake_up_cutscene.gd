@tool
extends Cutscene

@export_range(0.0, 3.0, 0.1, "suffix:s") 
var wake_up_delay: float = 1.5

@export var wake_up_dialogue: DialogueResource
@export var camera_target: Node3D
@export var camera_action: CameraAction
@export var wake_up_quest: Quest
@export var light_switch_interactable: Interactable

func _on_play() -> void:
	if Engine.is_editor_hint(): return
	
	Audio.pause_music(true)
	
	var player: Player = Global.player
	var player_fov: float = player.camera.fov
	camera_action.camera.make_current.call_deferred()
	
	await get_tree().create_timer(wake_up_delay).timeout
	
	camera_action.interpolate_camera(camera_action.global_transform, camera_target, player_fov, player_fov)
	await camera_action._interpolation_finished
	
	DialogueManager.show_dialogue_balloon(wake_up_dialogue,)
	await DialogueManager.dialogue_ended
	
	camera_action.interpolate_camera(camera_target.global_transform, player.camera, player_fov, player_fov)
	await camera_action._interpolation_finished
	
	QuestHandle.start_quest(wake_up_quest)
	
	wake_up_quest.task_updated.connect(_on_task_updated)
	
	player.set_state("Moving")
	

func _on_task_updated(t: Task) -> void:
	if t.task_name == "Teeth" and t.is_completed():
		wake_up_quest.task_updated.disconnect(_on_task_updated)
		light_switch_interactable.disabled = false
