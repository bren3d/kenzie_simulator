extends Node

signal quest_started(quest: Quest)
signal quest_finished(quest: Quest)

var active_quest: Quest

func start_quest(quest: Quest) -> void:
	active_quest = quest
	
	if quest:
		quest.finished.connect(emit_signal.bind(quest_finished.get_name(), quest))
		quest.start()
	
	quest_started.emit(quest)

func _input(event: InputEvent) -> void:
	if active_quest and event.is_action(&"ui_page_up") and event.is_pressed() and not event.is_echo():
		for t: Task in active_quest.get_active_tasks():
			active_quest.update_task_status(t.task_name, Task.STATUS_COMPLETED)
