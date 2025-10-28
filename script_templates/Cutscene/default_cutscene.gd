@tool
extends Cutscene



func _on_play() -> void:
	if Engine.is_editor_hint(): return
	
