@tool
extends EditorScript

func _run() -> void:
	print("Running...")
	for dic in get_scene().get_node("Interactable").get_property_list():
		print(dic)
