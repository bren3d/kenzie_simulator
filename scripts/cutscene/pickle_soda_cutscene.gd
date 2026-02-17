@tool
extends Cutscene

@export var quest: Quest

@export var lights_task: Task
@export var drink_task: Task
@export var eat_task: Task

@export var dialogue: DialogueResource

@export var pickle_interactable: Interactable
@export var soda_interactable: Interactable


func _ready() -> void:
	if Engine.is_editor_hint(): return
	quest.task_updated.connect(_on_task_updated)

func _on_task_updated(t: Task) -> void:
	if t.task_name == lights_task.task_name and t.is_completed():
		play.call_deferred()
		quest.task_updated.disconnect(_on_task_updated)

func enable_pickle() -> void:
	Global.active_stats.pickle = true
	Global.player.pickle_stat.disabled = false
	Global.player.pickle_stat.paused = false
	quest.update_task_progress(eat_task.task_name, Task.STATUS_COMPLETED)

func enable_soda() -> void:
	Global.active_stats.soda = true
	Global.player.soda_stat.disabled = false
	Global.player.soda_stat.paused = false
	quest.update_task_progress(drink_task.task_name, Task.STATUS_COMPLETED)

func _on_play() -> void:
	if Engine.is_editor_hint(): return
	
	DialogueManager.show_dialogue_balloon(dialogue)
	DialogueManager.dialogue_ended.connect(quest.advance_task.unbind(1), CONNECT_ONE_SHOT)
	DialogueManager.dialogue_ended.connect(finish.unbind(1), CONNECT_ONE_SHOT)
	
	pickle_interactable.interaction_started.connect(enable_pickle.unbind(1), CONNECT_ONE_SHOT)
	soda_interactable.interaction_started.connect(enable_soda.unbind(1), CONNECT_ONE_SHOT)
