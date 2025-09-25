@icon("res://assets/icons/icon_puzzle.png")
@tool
class_name Component extends Node
## A class meant to add functionality to a parent via a metadata tag.

func get_tag() -> StringName:
	return get_script().get_global_name()

func has_component(tag: StringName) -> bool:
	return get_parent().has_meta(tag) if get_parent() else false

func get_component(tag: StringName) -> Node:
	return get_parent().get_meta(tag) if has_component(tag) else null

static func node_component(parent_node: Node, tag: StringName) -> Node:
	return parent_node.get_meta(tag) if parent_node.has_component(tag) else null

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_ENTER_TREE when not Engine.is_editor_hint():
			get_parent().set_meta(get_tag(), self) # Reapply on enter tree due to HTML5 glitch.
		NOTIFICATION_PARENTED:
			get_parent().set_meta(get_tag(), self)
		NOTIFICATION_UNPARENTED:
			get_parent().set_meta(get_tag(), null)
		# Remove meta before save (prevents recursion issues)
		NOTIFICATION_EDITOR_PRE_SAVE:
			get_parent().set_meta(get_tag(), null)
		NOTIFICATION_EDITOR_POST_SAVE:
			get_parent().set_meta(get_tag(), self)
