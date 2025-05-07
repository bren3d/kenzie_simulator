@icon("res://assets/icons/icon_dialog.png")
@tool
class_name DialogueAction extends Node

signal dialogue_finished

@export var dialogue_resource: DialogueResource
@export var section_title: String = ""

@export var camera_action: CameraAction

func _ready() -> void:
	if Engine.is_editor_hint(): return
	assert(get_parent().has_meta(&"Interactable"))
	var interactable: Interactable = get_parent().get_meta(&"Interactable") as Interactable
	
	interactable.interaction_started.connect(start)
	dialogue_finished.connect(interactable.end_interaction)

func start(interactor: Object) -> void:
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	var states: Dictionary = {
		interactor = interactor, 
		interactable = get_parent(),
		}
	if interactor is Player:
		states.player = interactor
	if get_parent().has_meta(&"DialogueFocus"):
		states.focus_point = get_parent().get_meta(&"DialogueFocus")
	
	if camera_action:
		camera_action.focused.connect(DialogueManager.show_dialogue_balloon.bind(dialogue_resource, section_title, [states]), CONNECT_ONE_SHOT)
		camera_action.focus()
	else:
		DialogueManager.show_dialogue_balloon(dialogue_resource, section_title, [states])

func _on_dialogue_ended(dialogue: DialogueResource) -> void:
	if dialogue_resource != dialogue: return
	DialogueManager.dialogue_ended.disconnect(_on_dialogue_ended)
	if camera_action:
		camera_action.release_focus()
	dialogue_finished.emit()

func get_tag() -> StringName:
	return &"Dialogue"

#func _notification(what: int) -> void:
	#match what:
		#NOTIFICATION_PARENTED when not Engine.is_editor_hint():
			#get_parent().set_meta(get_tag(), self)
		#NOTIFICATION_UNPARENTED when not Engine.is_editor_hint():
			#get_parent().set_meta(get_tag(), null)
		#
		#NOTIFICATION_EDITOR_PRE_SAVE when not Engine.is_editor_hint(): # Remove meta before save (prevents recursion issues)
			#get_parent().set_meta(get_tag(), null)
		#NOTIFICATION_EDITOR_POST_SAVE when not Engine.is_editor_hint():
			#get_parent().set_meta(get_tag(), self)
