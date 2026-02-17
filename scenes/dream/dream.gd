@tool
extends Node3D

@export var basement_scene: PackedScene
@export var area_exit: Area3D

func _ready() -> void:
	if Engine.is_editor_hint(): return
	Global.play_wake_up_cutscene_on_ready = true

func _on_area_exit_body_exited(body: Node3D) -> void:
	if Engine.is_editor_hint() or not body is Player: return
	
	if not get_tree().is_changing_scenes: # Prevents double load.
		get_tree().change_scene_packed(basement_scene)
