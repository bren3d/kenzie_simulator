@tool
class_name ActionToggle extends Action

@export var target_node: NodePath
@export var property_name: StringName

@export var value_1: Variant
@export var value_2: Variant


func execute(refs: Dictionary = {}) -> void:
	if not property_name or not target_node:
		printerr("No target node/property name set in %s" % self)
		return
	
	if not refs.get("host", false):
		printerr("Could - Host not passed in references." % property_name)
		return
	
	var host: Node = refs.host as Node
	
	var target: Object = refs.host.get_node(target_node)
	
	if not target:
		printerr("Could not execute action with method_name '%s' - Passed target is not of type object." % property_name)
		return
	
	if target.get_indexed(NodePath(property_name)) != value_1:
		target.set_indexed(NodePath(property_name), value_1)
	else:
		target.set_indexed(NodePath(property_name), value_2)
