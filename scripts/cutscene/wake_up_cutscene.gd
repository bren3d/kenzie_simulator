@tool
extends Cutscene

@export var camera: Camera3D

func _on_play() -> void:
	var tw: Tween = create_tween()
	tw.tween_callback(camera.make_current)
	
