@tool
extends Node3D

func _ready() -> void:
	if Engine.is_editor_hint(): return
	$AreaExit.body_exited.connect(_on_area_body_exited)

func _on_area_body_exited(body: Node3D) -> void:
	if body is Player and not get_tree().is_changing_scenes:
		get_tree().change_scene(load("res://scenes/basement/basement.tscn").instantiate())
