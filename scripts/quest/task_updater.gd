@tool
class_name TaskUpdater extends Node

@export var quest: Quest:
	set(val):
		quest = val
		notify_property_list_changed()

@export var task_name: String

@export var update_progress: bool:
	set(val):
		update_progress = val
		notify_property_list_changed()

@export_enum("Not Started", "In Progress", "Completed") 
var updated_status: int = Task.STATUS_COMPLETED

@export_range(0.0, 10.0, 0.1, "or_greater", "or_less")
var progress_increment: float = 1.0


func update_task(custom_progress_increment: float = progress_increment) -> void:
	if update_progress:
		quest.add_task_progress(task_name, custom_progress_increment)
		return
	
	quest.update_task_status(task_name, updated_status)


func _validate_property(property: Dictionary) -> void:
	if not Engine.is_editor_hint(): return
	match property.name:
		"task_name", "updated_status", "update_progress", "progress_increment" when not quest:
			property.usage &= ~PROPERTY_USAGE_EDITOR
		
		"updated_status" when update_progress:
			property.usage &= ~PROPERTY_USAGE_EDITOR
		
		"progress_increment" when not update_progress:
			property.usage &= ~PROPERTY_USAGE_EDITOR
		
		"task_name":
			property.hint |= PROPERTY_HINT_ENUM_SUGGESTION
			property.hint_string = quest.get_tasks_hint_string()
