@tool
class_name AudioTrigger extends AudioStreamPlayer3D

func _ready() -> void:
	if Engine.is_editor_hint(): return
	if get_parent().has_meta(&"Interactable"):
		get_parent().get_meta(&"Interactable").interaction_started.connect(_on_interaction_started)

func _on_interaction_started(interactor: Object) -> void:
	if not playing: play()
