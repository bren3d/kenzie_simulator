@tool
extends Cutscene

@export var quest: Quest
@export var task: Task
@export var vagarant: Vagarant
@export var vagarant_viewport: Viewport
@export var computer_interactable: Interactable
@export var computer_cam: Camera3D

#var is_active: bool = false

func _ready() -> void:
	vagarant.hide_menu()
	computer_interactable.disabled = true
	
	quest.started.connect(_on_quest_started, CONNECT_ONE_SHOT)
	computer_interactable.interaction_started.connect(play.unbind(1))
	vagarant.request_exit.connect(_on_request_exit)
	vagarant.match_finished.connect(quest.update_task_status.bind(task.task_name, Task.STATUS_COMPLETED), CONNECT_ONE_SHOT | CONNECT_DEFERRED)

func _on_play() -> void:
	if Engine.is_editor_hint(): return
	#is_active = true
	computer_cam.make_current()
	vagarant.enter()

func _on_quest_started() -> void:
	computer_interactable.disabled = false
	vagarant.show_menu()

func _on_request_exit() -> void:
	is_active = false
	Global.player.make_camera_current()
	Global.player.set_state("Moving")

func _input(event: InputEvent) -> void:
	if not is_active: return
	vagarant_viewport.push_input(event)
	get_viewport().set_input_as_handled()
