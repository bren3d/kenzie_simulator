@tool
class_name Quest extends Resource

signal started
signal finished

signal task_updated(task: Task)
signal tasks_changed

@export_placeholder("Cow Slayer") var quest_name: String:
	set(val):
		quest_name = val
		resource_name = val

@export var auto_advance_tasks: bool = false
@export var auto_complete_quest: bool = true

@export var tasks: Array[Task] : set = set_tasks

## Will find the next uncompleted task(s) based on priority and will mark as 
## [enum Task.STATUS_IN_PROGRESS] accordingly.
func advance_task() -> void:
	var priority: int = Task.MIN_PRIORITY
	
	for i: int in tasks.size():
		if not tasks[i] or tasks[i].is_completed(): continue
		priority = tasks[i].priority
		break
	
	for t: Task in tasks:
		if t and t.priority == priority and not t.is_started():
			t.status = Task.STATUS_IN_PROGRESS
			task_updated.emit(t)
	
	if auto_complete_quest and get_active_tasks().is_empty():
		finish()

func start() -> void:
	advance_task()
	started.emit()


func finish() -> void:
	finished.emit()

## Returns [code]true[/code] if all tasks are marked as completed,
## returns [code]false[/code] otherwise.
func is_tasks_completed() -> bool:
	return tasks.all(func(t: Task) -> bool: return t.status == Task.STATUS_COMPLETED)

func update_task_status(task_name: String, status: int) -> void:
	set_task_status(get_task(task_name), status)

func set_task_status(t: Task, status: int) -> void:
	t.status = status
	task_updated.emit(t)
	if auto_advance_tasks and get_active_tasks().is_empty():
		advance_task()

func add_task_progress(task_name: String, additional_progress: float) -> void:
	var t := get_task(task_name)
	set_task_progress(t, t.current_progress_value + additional_progress)

func update_task_progress(task_name: String, progress_value: float) -> void:
	set_task_progress(get_task(task_name), progress_value)

func set_task_progress(t: Task, progress_value: float) -> void:
	t.set_current_progress_value(progress_value)
	if t.auto_complete:
		if not Engine.is_editor_hint() and \
		(t.current_progress_value >= t.max_progress_value) or is_equal_approx(t.current_progress_value, t.max_progress_value):
			# Call this function as to check for auto_advance_task accordingly
			set_task_status(t, Task.STATUS_COMPLETED) 
			return
	
	task_updated.emit(t)

func add_task(t: Task) -> void:
	tasks.push_back(t)
	tasks = tasks


func get_task(task_name: String) -> Task:
	for t: Task in tasks:
		if t.task_name == task_name:
			return t
	push_warning("Task with name '%s' not found." % task_name)
	return null

func get_active_tasks() -> Array[Task]:
	var active_tasks: Array[Task]
	for t: Task in tasks:
		if t.is_active():
			active_tasks.push_back(t)
	return active_tasks

func set_tasks(val: Array[Task]) -> void:
	for i: int in val.size():
		if not val[i]: 
			val[i] = Task.new()
	
	val.sort_custom(sort_task_priority)
	tasks = val
	tasks_changed.emit()


func sort_task_priority(a: Task, b: Task) -> bool:
	return a.priority < b.priority if a and b else false

## Helper function for tool scripts to populate task names use.
func get_tasks_hint_string() -> String:
	var task_names: PackedStringArray
	for t: Task in tasks:
		task_names.push_back(t.task_name)
	return ",".join(task_names)
