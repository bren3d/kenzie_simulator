@tool
class_name NPC extends Node3D

@onready var focus: Node3D = $Focus

func _ready() -> void:
	if not Engine.is_editor_hint():
		set_meta(&"Focus", focus)
