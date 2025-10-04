@tool
extends EditorScript
@export_placeholder("Method/Property Name...") var subname: String = ""
func _run() -> void:
	print("Running...")
	#import_assets("res://scenes/objects/")
	generate_scene_previews("res://scenes/objects/cleaning/")
	#generate_scene_previews("res://scenes/objects/laundry/")

func generate_scene_previews(dir: String, recursive: bool = false) -> void:
	for fp: String in DirAccess.get_files_at(dir):
		EditorInterface.open_scene_from_path(dir.path_join(fp))
		EditorInterface.save_scene()
		EditorInterface.close_scene()
	
	if not recursive: return
	for subdir: String in DirAccess.get_directories_at(dir):
		generate_scene_previews(dir.path_join(subdir), true)

func import_assets(save_dir: String = "") -> void:
	if not save_dir: return
	#var save_dir: String = "res://scenes/objects/chairs/"
	var root_node: Node = get_scene().get_node_or_null(^"RootNode")
	if not root_node: 
		push_warning("No 'RootNode' found in current scene.")
		return
	
	for child in root_node.get_children():
		if child is Node3D:
			child.position = Vector3.ZERO
			child.scale = Vector3.ONE
		
		for subchild in child.get_children():
			subchild.propagate_call(&"set_owner", [child], )
		
		var file_name: String = child.name.to_snake_case() + ".tscn"
		var scene_file_path: String = save_dir.path_join(file_name)
		
		var packed: PackedScene = PackedScene.new()
		var result: int = packed.pack(child)
		if result == OK:
			var error: int = ResourceSaver.save(packed, scene_file_path)
			if error != OK:
				printerr("SAVING ERROR(%s): " % scene_file_path + error_string(error))
			else:
				print_rich("[color=green]Successfully saved: %s[/color]" % scene_file_path)
				child.scene_file_path = scene_file_path
		else:
			print("PACKING ERROR(%s): " % scene_file_path + error_string(result))
		
