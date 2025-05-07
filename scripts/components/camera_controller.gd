@tool
class_name CameraController extends Node3D
## Provides camera helper functions.

const MAX_PITCH: float = PI / 2.025
const ZOOM_DURATION_SEC: float = 0.25

const DEFAULT_DURATION_SEC: float = 0.4

@export var player: Node3D
@export var camera: Camera3D

@export var _trans: Tween.TransitionType = Tween.TRANS_SINE
@export var _ease: Tween.EaseType = Tween.EASE_IN_OUT

@export_storage var default_fov: float = 75.0
@export var debug: bool = true : set = set_debug

var origin: Vector3

var zoom: float = 1.0: set = set_zoom
func set_zoom(val: float) -> void:
	if zoom == val: return
	zoom = val
	if not Engine.is_editor_hint() and camera:
		create_tween().tween_property(camera, ^"fov", default_fov/zoom, ZOOM_DURATION_SEC).set_delay(0.2 if tw and tw.is_running() else 0.0)

var focus_point: Vector3
var focus_active: bool

var tw: Tween

var debug_mesh: MeshInstance3D

func _init() -> void:
	if not OS.is_debug_build() or debug_mesh: return
	debug_mesh = MeshInstance3D.new()
	debug_mesh.top_level = true
	add_child(debug_mesh)
	debug_mesh.mesh = SphereMesh.new() as SphereMesh
	debug_mesh.mesh.height = 0.2
	debug_mesh.mesh.radius = debug_mesh.mesh.height / 2.0
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_color = Color(1.0, 0.0, 1.0, 0.6)
	debug_mesh.mesh.material = material
	debug_mesh.visible = false


func get_camera_pitch() -> float:
	return camera.rotation.x

func set_camera_pitch(pitch: float) -> void:
	camera.rotation.x = clampf(pitch, -MAX_PITCH, MAX_PITCH)

func look_toward(point: Vector3, duration_sec: float = DEFAULT_DURATION_SEC) -> void:
	var pos_delta: Vector3 = point - camera.global_position
	
	var yaw: float = atan2( -pos_delta.x, -pos_delta.z,)
	var yaw_delta: float = angle_difference(player.rotation.y, yaw,)
	var target_yaw: float = player.rotation.y + yaw_delta
	
	var pitch: float = atan2(pos_delta.y, Vector2(pos_delta.x, pos_delta.z).length(),)
	var pitch_delta: float = angle_difference(camera.rotation.x, pitch)
	var target_pitch: float = clampf(camera.rotation.x + pitch_delta, -MAX_PITCH, MAX_PITCH)
	
	if tw and tw.is_valid():
		tw.kill()
	
	tw = create_tween().set_ease(_ease).set_trans(_trans).set_parallel()
	tw.tween_property(player, ^"rotation:y", target_yaw, duration_sec)
	#tw.tween_property(camera, "camera")
	tw.tween_method(set_camera_pitch, get_camera_pitch(), target_pitch, duration_sec)
	
	if debug_mesh and debug: 
		debug_mesh.visible = true
		debug_mesh.global_position = focus_point 

func focus(point: Vector3) -> void:
	print("Focusing: %1.1v -> %1.1v" % [camera.global_position, point])
	assert(point != camera.global_position)
	focus_point = point
	focus_active = true
	set_notify_transform(true)
	look_toward(point)

func release_focus() -> void:
	focus_active = false
	set_notify_transform(false)
	if tw and tw.is_valid():
		tw.kill()

func reset_zoom() -> void:
	zoom = 1.0

## Releases focus and resets zoom.
func release_all() -> void:
	release_focus()
	reset_zoom()
	set_indexed(^"debug_mesh:visible", false)

func focus_current_interactable() -> void:
	if not Interactable.active_interactable or not Interactable.active_interactable.has_meta(&"Focus"): return
	focus(Interactable.active_interactable.get_meta(&"Focus").global_position)

func set_debug(val: bool) -> void:
	debug = val
	if debug_mesh: 
		debug_mesh.visible = debug

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_READY:
			if camera: 
				position = camera.position 
		
		NOTIFICATION_TRANSFORM_CHANGED when transform.origin != origin:
			origin = transform.origin # Tracks only movement not rotation.
			if focus_active:
				look_toward(focus_point)
				
		
		NOTIFICATION_EDITOR_PRE_SAVE when camera:
			default_fov = camera.fov
