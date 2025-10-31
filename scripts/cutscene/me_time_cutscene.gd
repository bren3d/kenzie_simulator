@tool
extends Cutscene

@export var list_quest: Quest
#@export var task_name: String = "sweep"

@export var dialogue: DialogueResource

@export var me_time_quest: Quest

func _ready() -> void:
	super()
	if not Engine.is_editor_hint():
		list_quest.finished.connect(play, CONNECT_ONE_SHOT)

func _on_play() -> void:
	if Engine.is_editor_hint(): return
	DialogueManager.show_dialogue_balloon(dialogue)
	
	await DialogueManager.dialogue_ended
	
	QuestHandle.start_quest(me_time_quest)
	Global.player.set_state("Moving")
