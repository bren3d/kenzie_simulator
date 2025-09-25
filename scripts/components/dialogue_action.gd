@icon("res://assets/icons/icon_dialog.png")
@tool
class_name DialogueAction extends Node

signal dialogue_finished

@export var dialogue_resource: DialogueResource
@export var section_title: String = ""
@export var disabled: bool

@export var camera_action: CameraAction

func _ready() -> void:
	if Engine.is_editor_hint(): return
	assert(get_parent().has_meta(&"Interactable"))
	
	var interactable:= get_parent().get_meta(&"Interactable") as Interactable
	interactable.interaction_started.connect(start)
	dialogue_finished.connect(interactable.end_interaction)

func start(interactor: Object) -> void:
	if disabled: return
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	var states: Dictionary = {
		interactor = interactor, 
		interactable = get_parent(),
		}
	
	if get_parent().has_meta(&"Focus"):
		states.focus = get_parent().get_meta(&"Focus")
	
	if camera_action:
		camera_action.focus_entered.connect(DialogueManager.show_dialogue_balloon.bind(dialogue_resource, section_title, [states]), CONNECT_ONE_SHOT)
		camera_action.focus()
	
	else:
		DialogueManager.show_dialogue_balloon(dialogue_resource, section_title, [states])

func _on_dialogue_ended(dialogue: DialogueResource) -> void:
	if dialogue_resource != dialogue: return
	DialogueManager.dialogue_ended.disconnect(_on_dialogue_ended)
	if camera_action:
		camera_action.focus_released.connect(emit_signal.bind(&"dialogue_finished"), CONNECT_ONE_SHOT)
		camera_action.release_focus()
	else:
		dialogue_finished.emit()

func get_tag() -> StringName:
	return &"Dialogue"
