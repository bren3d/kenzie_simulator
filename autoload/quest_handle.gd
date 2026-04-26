extends Node

signal quest_started(quest: Quest)
signal quest_finished(quest: Quest)

var active_quest: Quest
var started_quests: Array[Quest]

func start_quest(quest: Quest) -> void:
	active_quest = quest
	
	if quest:
		if not quest in started_quests:
			started_quests.push_back(quest)
		
		var finished_callable: Callable = emit_signal.bind(quest_finished.get_name(), quest)
		if not quest.finished.is_connected(finished_callable):
			quest.finished.connect(finished_callable)
		quest.start()
	
	quest_started.emit(quest)

func reset() -> void:
	for dict: Dictionary in get_incoming_connections():
		dict.signal.disconnect(dict.callable)

	for quest: Quest in started_quests:
		if quest:
			quest.reset(false)

	started_quests.clear()
	active_quest = null

func _input(event: InputEvent) -> void:
	if active_quest and event.is_action(&"ui_page_up") and event.is_pressed() and not event.is_echo():
		for t: Task in active_quest.get_active_tasks():
			active_quest.update_task_status(t.task_name, Task.STATUS_COMPLETED)
