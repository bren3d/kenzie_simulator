@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run() -> void:
	printt(ClassDB.class_get_enum_constants(&"DisplayServer", &"WindowMode"))
