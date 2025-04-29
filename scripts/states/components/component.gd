@tool
class_name Component extends Node
## A class meant to add functionality to a parent via a metadata tag.

func get_tag() -> StringName:
	return get_script().get_global_name()

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_PARENTED:
			get_parent().set_meta(get_tag(), self)
		NOTIFICATION_UNPARENTED:
			get_parent().set_meta(get_tag(), null)
