@tool
extends Node

var player: Player

func _init() -> void:
	if not Engine.has_singleton(&"Global"):
		Engine.register_singleton(&"Global", self)
