@tool
class_name ActionBasic extends Action

@export_node_path var target_node: NodePath

@export_placeholder("foo") var method_name: String = ""
@export var args: Array
@export var ref_arguments: PackedStringArray

@export var toggle_mode: bool:
	set(val):
		toggle_mode = val
		notify_property_list_changed()

func execute(refs: Dictionary = {host = null}) -> void:
	
	if not refs.get("host", false):
		printerr("Could - Host not passed in references." % method_name)
		return
	
	var host: Node = refs.host as Node
	
	var target: Object = refs.host.get_node(target_node)
	
	if not target:
		printerr("Could not execute action with method_name '%s' - Passed target is not of type object." % method_name)
		return
	
	if toggle_mode:
		target.set(method_name, !target.get(method_name))
		return
	
	var arguments: Array = args.duplicate()
	for key: String in ref_arguments:
		if not key in refs: continue
		arguments.push_back(refs[key])
	
	var action_callable: Callable = Callable(target, method_name)
	if not action_callable.is_valid():
		printerr("Could not execute action with method_name '%s' - Callable Invalid." % method_name)
		return
	
	action_callable.callv(arguments)

#region Property Validation

func _validate_property(property: Dictionary) -> void:
	if not Engine.is_editor_hint(): return
	match property.name:
		"ref_arguments", "args" when toggle_mode:
			property.usage &= ~(PROPERTY_USAGE_EDITOR)
		"method_name" when toggle_mode:
			property.name = "property_name"

func _get(property: StringName) -> Variant:
	return method_name if property == "property_name" else null

func _set(property: StringName, value: Variant) -> bool:
	if property == "property_name":
		method_name = value
		return true
	return false

#endregion Property Validation
