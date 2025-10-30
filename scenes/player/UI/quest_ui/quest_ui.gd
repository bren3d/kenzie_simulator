@tool
class_name QuestUI extends Control
@export_tool_button("Toggle Task Completed")
var toggle_task_completed: Callable = toggle_task_example_completed

@export var active_quest: Quest : set = set_active_quest

@export var font_color_active: Color = Color.WHITE
@export var font_color_inactive: Color = Color.DIM_GRAY

@export var strikethrough_texture: Texture2D

@export_group("Node References")
@export var quest_label: Label
@export var tasks_control: Control
@export var task_label_example: Label

var task_labels: Dictionary[Task, Label]

func _ready() -> void:
	if Engine.is_editor_hint(): return
	
	task_label_example.hide()
	set_active_quest(null)
	QuestHandle.quest_started.connect(_on_quest_started)

func toggle_task_example_completed() -> void:
	if task_label_example.draw.is_connected(_on_completed_task_label_draw):
		task_label_example.draw.disconnect(_on_completed_task_label_draw)
		task_label_example.add_theme_color_override(&"font_color", font_color_active)
	else:
		task_label_example.draw.connect(_on_completed_task_label_draw.bind(task_label_example))
		task_label_example.add_theme_color_override(&"font_color", font_color_inactive)
	
	task_label_example.queue_redraw()

func get_task_label_text(t: Task) -> String:
	var s: String = t.task_display_string
	if t.display_progress:
		if t.display_as_percent:
			s += " %3d" % t.get_progress_percent()
		else:
			s += " %d of %d" % [t.current_progress_value, t.max_progress_value]
	return s
		

func update_task(t: Task) -> void:
	if not t in task_labels: 
		push_warning("'%s' task label not found!" % t.task_name )
		return
	
	task_labels[t].text = get_task_label_text(t)
	
	# Hides task if applicable
	task_labels[t].visible = not t.hide_until_started or t.is_started()
	
	task_labels[t].add_theme_color_override(&"font_color", font_color_active if t.is_active() else font_color_inactive)
	
	if t.is_completed():
		task_labels[t].draw.connect(_on_completed_task_label_draw.bind(task_labels[t]))
	
	elif task_labels[t].draw.is_connected(_on_completed_task_label_draw):
		task_labels[t].draw.disconnect(_on_completed_task_label_draw)

func populate_tasks() -> void:
	clear_tasks()
	
	if not active_quest: return
	
	for t: Task in active_quest.tasks:
		var lbl: Label = task_label_example.duplicate()
		task_labels[t] = lbl
		tasks_control.add_child(lbl)
		update_task(t)

func clear_tasks() -> void:
	task_labels.clear()
	for child in tasks_control.get_children():
		if child == task_label_example: continue
		child.queue_free()

func _on_quest_started(quest: Quest) -> void:
	active_quest = quest

func set_active_quest(val: Quest) -> void:
	if active_quest:
		active_quest.task_updated.disconnect(update_task)
		active_quest.tasks_changed.disconnect(populate_tasks)
	
	active_quest = val
	
	if active_quest:
		active_quest.task_updated.connect(update_task)
		active_quest.tasks_changed.connect(populate_tasks)
	
	quest_label.text = active_quest.quest_name if active_quest else ""
	
	populate_tasks()

func _on_completed_task_label_draw(lbl: Label) -> void:
	#const LINE_EXTEND_AMOUNT: float = 2.0
	#const LINE_WIDTH: float = 1.0
	#const LINE_DASH: float = 2.0
	#const LINE_ANTIALIASED: bool = false
	#var line_start: Vector2 = Vector2(-LINE_EXTEND_AMOUNT, lbl.size.y/2.0 - LINE_EXTEND_AMOUNT)
	#var line_end: Vector2 = line_start + Vector2(lbl.size.x + LINE_EXTEND_AMOUNT, LINE_EXTEND_AMOUNT * 2.0)
	
	#lbl.draw_dashed_line(line_start, line_end, font_color_inactive, LINE_WIDTH, LINE_DASH, LINE_ANTIALIASED)
	const X_EXTEND_DISTANCE: float = 4.0
	
	var rect: Rect2 = lbl.get_rect()
	rect.size.y /= 2.0
	rect.position.y = rect.size.y / 1.5
	rect.position.x = -X_EXTEND_DISTANCE
	rect.size.x += X_EXTEND_DISTANCE * 2.0
	
	lbl.draw_texture_rect(strikethrough_texture, rect, false)
