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
