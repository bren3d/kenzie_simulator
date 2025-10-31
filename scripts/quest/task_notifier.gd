@tool
class_name TaskNotifier extends Node
## Emits signals when certain tasks are updated.

signal task_started
signal task_completed

#signal task_progress_changed(new_progress: float)

@export var quest: Quest:
	set(val):
		quest = val
		notify_property_list_changed()

@export var task_name: String

#var task_progress: float = 0.0

func _ready() -> void:
	if Engine.is_editor_hint(): return
	quest.task_updated.connect(_on_task_updated)
	quest.get_task(task_name)

func _on_task_updated(t: Task) -> void:
	if t.task_name != task_name: return
	
	if t.is_completed():
		task_completed.emit()
	elif t.is_started():
		task_started.emit()


func _validate_property(property: Dictionary) -> void:
	if not Engine.is_editor_hint(): return
	match property.name:
		"task_name" when not quest:
			property.usage &= ~PROPERTY_USAGE_EDITOR

		
		"task_name":
			property.hint |= PROPERTY_HINT_ENUM_SUGGESTION
			property.hint_string = quest.get_tasks_hint_string()
