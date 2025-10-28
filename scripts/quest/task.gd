@tool
class_name Task extends Resource
## A simple objective for use in Quest.

const MIN_PRIORITY: int = -4096
const MAX_PRIORITY: int = 4096

enum {STATUS_NOT_STARTED, STATUS_IN_PROGRESS, STATUS_COMPLETED}

## Name of task used to identify it.
@export_placeholder("cows") var task_name: String

## Text to display in UI along with progress if [member display_progress] is [code]true[/code].
@export_placeholder("Kill Cows") var task_display_string: String

## Used by Quest to determine order of tasks, a lower
## value priority task must be completed before a higher value task.
@export_range(MIN_PRIORITY, MAX_PRIORITY, 1, "hide_slider") var priority: int = 0

## Current status of task.
@export_enum("Not Started", "In Progress", "Completed") 
var status: int = STATUS_NOT_STARTED

## Task will not display in list until reaching its priority bracket.
@export var hide_until_started: bool

## Task can be partially completed and will display the current progress.
@export var display_progress: bool:
	set(val):
		display_progress = val
		notify_property_list_changed()

## Task will display progress as a whole number percentage value e.g. 57%.
@export var display_as_percent: bool:
	set(val):
		display_as_percent = val
		notify_property_list_changed()

@export var current_progress_value: float = 0.0: set = set_current_progress_value
@export var max_progress_value: float = 0.0

func is_started() -> bool:
	return status != STATUS_NOT_STARTED

func is_active() -> bool:
	return status == STATUS_IN_PROGRESS

func is_completed() -> bool:
	return status == STATUS_COMPLETED

func set_current_progress_value(val: float) -> void:
	current_progress_value = minf(val, max_progress_value)

func get_progress_percent() -> int:
	return roundi((current_progress_value / maxf(max_progress_value, 0.001)) * 100.0)

func get_progress_string() -> String:
	if not display_progress: 
		return ""
	
	if display_as_percent:
		return "%3d%%" % get_progress_percent()
	
	return "%d/%d" % [roundi(current_progress_value), roundi(max_progress_value)]


func _validate_property(property: Dictionary) -> void:
	if not Engine.is_editor_hint(): return
	match property.name:
		"display_as_percent", "current_progress_value", "max_progress_value" when not display_progress:
			property.usage &= ~PROPERTY_USAGE_EDITOR

func _get_property_list() -> Array[Dictionary]:
	var props: Array[Dictionary]
	props.push_back({
		name = "progress",
		type = TYPE_STRING,
		usage = PROPERTY_USAGE_EDITOR * int(display_progress) | PROPERTY_USAGE_READ_ONLY
	})
	return props

func _get(property: StringName) -> Variant:
	match property:
		"progress": 
			return get_progress_string()
	return null
