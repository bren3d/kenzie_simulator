extends Node3D

@export var quest: Quest
@export var task_name: String = "broom"

func _ready() -> void:
	quest.task_updated.connect(_on_task_updated)

func _on_task_updated(t: Task) -> void:
	if t.task_name == task_name and t.is_started():
		var interactable: Interactable = get_meta(&"Interactable")
		interactable.disabled = false
		quest.task_updated.disconnect(_on_task_updated)
		interactable.interaction_started.connect(_on_interaction_started, CONNECT_ONE_SHOT)

func _on_interaction_started(interactor: Object) -> void:
	hide()
	get_meta(&"Interactable").disabled = true
	quest.advance_task()
