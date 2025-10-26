@icon("res://assets/icons/icon_dialog.png")
@tool
class_name DialogueAction extends Node

signal dialogue_finished

@export var dialogue_resource: DialogueResource

@export_placeholder("Hello, this is dialogue...") 
var dialogue_text: String = ""

@export var simple_dialogue_mode: bool:
	set(val):
		simple_dialogue_mode = val
		notify_property_list_changed()

@export var section_title: String = ""
@export var disabled: bool

@export var camera_action: CameraAction

func _ready() -> void:
	if Engine.is_editor_hint(): return
	assert(get_parent().has_meta(&"Interactable"))
	
	if simple_dialogue_mode:
		dialogue_resource = DialogueManager.create_resource_from_text(dialogue_text)
	
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

func _validate_property(property: Dictionary) -> void:
	if simple_dialogue_mode and property.name == "dialogue_resource":
		property.usage &= ~(PROPERTY_USAGE_EDITOR)
	elif not simple_dialogue_mode and property.name == "dialogue_text":
		property.usage &= ~(PROPERTY_USAGE_EDITOR)
