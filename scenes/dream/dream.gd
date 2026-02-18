@tool
extends Node3D

@export var basement_scene: PackedScene
@export var player_scene: PackedScene

func play() -> void:
	add_child(player_scene.instantiate())
	Global.play_wake_up_cutscene_on_ready = true

func _on_area_exit_body_exited(body: Node3D) -> void:
	if Engine.is_editor_hint() or not body is Player: return
	if body.position.length() < 150.0: return
	print("BODY EXITED AREA")
	get_tree().change_scene_packed(basement_scene)
	
