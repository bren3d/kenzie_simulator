@tool
class_name Quest extends Resource

signal started
signal finished

#signal task_started(task: Task)
signal task_updated(task: Task)
#signal task_ended(task: Task)

@export_placeholder("Cow Slayer") var quest_name: String:
	set(val):
		quest_name = val
		resource_name = val

@export var auto_advance_tasks: bool = true

@export var tasks: Array[Task] : set = set_tasks

func start() -> void:
	var priority: int = Task.MIN_PRIORITY
	
	
	
	for i: int in tasks.size():
		if not tasks[i] or tasks[i].is_completed(): continue
		priority = tasks[i].priority
		break
	
	for t: Task in tasks:
		if t.priority == priority and not t.is_completed():
			t.status = Task.STATUS_IN_PROGRESS
			task_updated.emit(t)
			
		
	started.emit()

func finish() -> void:
	finished.emit()

## Returns [code]true[/code] if all tasks are marked as completed,
## returns [code]false[/code] otherwise.
func is_tasks_completed() -> bool:
	return tasks.all(func(t: Task) -> bool: return t.status == Task.STATUS_COMPLETED)

func update_task_status(task_name: String, status: int) -> void:
	var t := get_task(task_name)
	t.status = status
	task_updated.emit(t)


func update_task_progress(task_name: String, progress_value: float) -> void:
	var t := get_task(task_name)
	t.set_current_progress_value(progress_value)
	task_updated.emit(t, )

func get_task(task_name: String) -> Task:
	for t: Task in tasks:
		if t.task_name == task_name:
			return t
	push_warning("Task with name '%s' not found." % task_name)
	return null


func set_tasks(val: Array[Task]) -> void:
	for i: int in val.size():
		if not val[i]: 
			val[i] = Task.new()
	
	val.sort_custom(sort_task_priority)
	tasks = val


func sort_task_priority(a: Task, b: Task) -> bool:
	return a.priority < b.priority if a and b else false
