@tool
extends EditorScript
@export_placeholder("Method/Property Name...") var subname: String = ""
func _run() -> void:
	print("Running...")
	var cam:= Camera3D.new()
	#cam.get_property_list()
	#print(^"./Child/NodeSub:texture".get_concatenated_names())
	#
	for dic in cam.get_property_list():
		if "Camera3D" in dic.name:
			print(dic)
	#for dic in get_scene().get_node("Interactable").get_property_list():
		#print(dic)
