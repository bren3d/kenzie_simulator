@tool
extends Cutscene

@export var list_quest: Quest
@export var task_name: String = "sweep"

@export var dialogue: DialogueResource

@export var me_time_quest: Quest

func _ready() -> void:
	super()
	if not Engine.is_editor_hint():
		list_quest.task_updated.connect(_on_task_updated)

func _on_task_updated(t: Task) -> void:
	if t.task_name == task_name and t.is_completed():
		list_quest.task_updated.disconnect(_on_task_updated)
		play()

func _on_play() -> void:
	if Engine.is_editor_hint(): return
	DialogueManager.show_dialogue_balloon(dialogue)
	
	await DialogueManager.dialogue_ended
	
	QuestHandle.start_quest(me_time_quest)
	Global.player.set_state("Moving")
