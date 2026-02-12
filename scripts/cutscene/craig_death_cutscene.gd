@tool
extends Cutscene

@export var deer: Node3D
@export var deer_target_location: Marker3D
@export var lights: Node3D

func _on_play() -> void:
	if Engine.is_editor_hint(): return
	lights.hide()
	deer.global_transform = deer_target_location.global_transform
