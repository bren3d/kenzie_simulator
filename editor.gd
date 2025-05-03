@tool
extends EditorScript

signal hover_started(obj: Interactable)
signal hover_ended(obj: Interactable)

signal interaction_started(obj: Interactable)
signal interaction_ended(obj: Interactable)

func _run() -> void:
	print("Running...")
	#add_user_signal()
	for sig: Dictionary in Engine.get_signal_list():
		printt(sig)
