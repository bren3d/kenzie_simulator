@tool
class_name TriggeredAction extends Node

@export_tool_button("Trigger Action", "Debug")
var action_trigger_callable: Callable = trigger

@export_node_path var target_node_path: NodePath

@export var method_name: String

## Changes a bool property to the opposite state. Use [member method_name] to set the property name.
@export var toggle_mode: bool:
	set(val):
		toggle_mode = val
		notify_property_list_changed()

@export_storage var arguments: Array

func _ready() -> void:
	var interactable: Interactable = get_parent().get_meta(&"Interactable")
	interactable.interaction_started.connect(trigger)

func trigger(interactor: Object = null) -> void:
	var obj:= get_object()
	assert(obj, "No object found!")
	assert(method_name in obj, "'%s' not found in object %s." % [method_name, obj])
	
	if toggle_mode:
		obj.set(method_name, !obj.get(method_name))
		return
	
	var callable:= Callable(obj, method_name)
	callable.callv(arguments)

func get_object() -> Object:
	return get_node_and_resource(target_node_path)[1] if get_node_and_resource(target_node_path)[1] else get_node_and_resource(target_node_path)[0]

func _validate_property(property: Dictionary) -> void:
	if not Engine.is_editor_hint(): return
	
	match property.name:
		&"arguments" when not toggle_mode:
			property.usage |= PROPERTY_USAGE_EDITOR
