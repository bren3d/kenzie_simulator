@tool
class_name AnimatedCamera extends Node3D

@export_tool_button("Select Camera", "Camera3D")
var select_camera_callable: Callable = func () -> void:
		if not Engine.has_singleton(&"EditorInterface"): return
		Engine.get_singleton(&"EditorInterface").get_selection().clear()
		Engine.get_singleton(&"EditorInterface").get_selection().add_node(camera)

var camera: Camera3D = Camera3D.new()
var target_position: Vector3

func _init() -> void:
	camera.visible = false
	add_child(camera)
	top_level = true

func _ready() -> void:
	set_physics_process(false)

#func interpolate_from_current()


func select_camera() -> void:
	if not Engine.has_singleton(&"EditorInterface"): return
	Engine.get_singleton(&"EditorInterface").get_selection().clear()
	Engine.get_singleton(&"EditorInterface").get_selection().add_node(camera)



func _get_property_list() -> Array[Dictionary]:
	return ClassDB.class_get_property_list(&"Camera3D", true)

func _get(property: StringName) -> Variant:
	if camera and property in ClassDB.class_get_property_list(&"Camera3D", true).map(func(d: Dictionary) -> StringName: return d.name):
		return camera.get(property)
	return null

func _set(property: StringName, value: Variant) -> bool:
	if camera and property in ClassDB.class_get_property_list(&"Camera3D", true).map(func(d: Dictionary) -> StringName: return d.name):
		camera.set(property, value)
		return true
	return false
