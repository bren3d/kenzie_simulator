@icon("res://assets/icons/icon_camera_grid.png")
@tool
class_name CameraAction extends Marker3D

## For internal use.
signal _interpolation_finished

signal focus_entered
signal focus_released

enum ReleaseMode {MODE_ORIGINAL_CAMERA, MODE_NONE}

## Use to see current camera position 
@export_tool_button("Select Camera", "Camera3D")
var select_camera_callable: Callable = func () -> void:
		if not Engine.has_singleton(&"EditorInterface"): return
		Engine.get_singleton(&"EditorInterface").get_selection().clear()
		Engine.get_singleton(&"EditorInterface").get_selection().add_node(camera)

# TODO - Change behavior with modes...
@export var release_mode: ReleaseMode = ReleaseMode.MODE_ORIGINAL_CAMERA

@export_range(0.0, 3.0, 0.05, "or_greater", "suffix:s") 
var tween_duration_sec: float = 1.0

@export_group("Tweening")

@export var trans_type: Tween.TransitionType = Tween.TRANS_SPRING
@export var ease_type: Tween.EaseType = Tween.EASE_IN_OUT

@export_storage var camera_properties: Dictionary:
	set(val):
		camera_properties = val
		if val: for property: String in val.keys():
			camera.set(property, val[property])

var camera: Camera3D = Camera3D.new()

var camera_to_restore: Camera3D

#region Tween Properties

var initial_fov: float = 75.0
var target_fov: float = 75.0

var initial_transform: Transform3D = Transform3D()
var target_node: Node3D

var elapsed_sec: float = 0.0

#endregion Tween Properties

func _init() -> void:
	var cam_props: Dictionary = {}
	for prop in ClassDB.class_get_property_list(&"Camera3D", true):
		cam_props[prop.name] = camera.get(prop.name)
	camera_properties = cam_props
	add_child(camera)

func _ready() -> void:
	set_notify_transform(Engine.is_editor_hint())
	camera.top_level = true
	camera.clear_current()
	camera.global_transform = global_transform
	set_physics_process(false)


func is_focused() -> bool:
	return is_physics_processing()


func interpolate_camera(from: Transform3D, to: Node3D, start_fov: float = 75.0, final_fov: float = 75.0) -> void:
	initial_transform = from
	camera.global_transform = from
	target_node = to
	
	initial_fov = start_fov
	camera.fov = start_fov
	target_fov = final_fov
	
	camera.make_current()
	
	elapsed_sec = 0.0
	set_physics_process(true)

# TODO - Change behavior with modes...
func focus() -> void:
	var current_camera: Camera3D = get_viewport().get_camera_3d()
	if current_camera != self:
		camera_to_restore = current_camera
	interpolate_camera(camera_to_restore.global_transform, self, camera_to_restore.fov, camera_properties.get("fov", 75.0))
	if _interpolation_finished.is_connected(restore_camera):
		_interpolation_finished.disconnect(restore_camera)
	_interpolation_finished.connect(emit_signal.bind(&"focus_entered"), CONNECT_ONE_SHOT)

# TODO - Change behavior with modes...
func release_focus() -> void:
	interpolate_camera(camera.global_transform, camera_to_restore, camera.fov, camera_to_restore.fov)
	_interpolation_finished.connect(restore_camera, CONNECT_ONE_SHOT)

func restore_camera() -> void:
	if Engine.is_editor_hint(): return
	set_physics_process(false)
	if release_mode == ReleaseMode.MODE_ORIGINAL_CAMERA:
		assert(camera_to_restore != null, "No camera to restore!")
		camera_to_restore.make_current()
	focus_released.emit() # Rely on this signal for other camera to take focus away...

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	if elapsed_sec >= tween_duration_sec:
		_interpolation_finished.emit()
		return
	
	assert(target_node != null, )
	
	elapsed_sec = minf(elapsed_sec + delta , tween_duration_sec)
	var t: float = Tween.interpolate_value(0.0, 1.0, elapsed_sec, tween_duration_sec, trans_type, ease_type)
	camera.global_transform = initial_transform.interpolate_with(target_node.global_transform, t)
	
	var final_fov: float = target_node.fov if target_node is Camera3D else target_fov
	camera.fov = lerpf(initial_fov, final_fov, t)


func _get_property_list() -> Array[Dictionary]:
	var props: Array[Dictionary] = [{"name": "Camera3D", "class_name": &"", "type": 0, "hint": 0, "hint_string": "Camera3D", "usage": 128}]
	return props + ClassDB.class_get_property_list(&"Camera3D", true)

func _get(property: StringName) -> Variant:
	if camera and property in ClassDB.class_get_property_list(&"Camera3D", true).map(func(d: Dictionary) -> StringName: return d.name):
		return camera_properties.get(property)
	return null

func _set(property: StringName, value: Variant) -> bool:
	if camera and property in ClassDB.class_get_property_list(&"Camera3D", true).map(func(d: Dictionary) -> StringName: return d.name):
		camera_properties[property] = value
		camera.set(property, value)
	return false

func _notification(what: int) -> void:
	if not Engine.is_editor_hint(): return
	match what:
		NOTIFICATION_TRANSFORM_CHANGED:
			camera.global_transform = global_transform
