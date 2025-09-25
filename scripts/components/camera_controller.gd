@tool
class_name CameraController extends Node
## Provides camera helper functions.

const MAX_PITCH: float = PI / 2.025
const ZOOM_DURATION_SEC: float = 0.25

const DEFAULT_DURATION_SEC: float = 0.5

signal tween_started
signal tween_finished

@export var player: Node3D
@export var camera: Camera3D

@export var _trans: Tween.TransitionType = Tween.TRANS_SINE
@export var _ease: Tween.EaseType = Tween.EASE_IN_OUT

@export_storage var default_fov: float = 75.0
@export var debug: bool = true : set = set_debug
var debug_mesh: MeshInstance3D

var origin: Vector3

var zoom: float = 1.0: set = set_zoom

var focused_node: Node3D

## Updated to refresh active tween.
var focus_point: Vector3
var focus_active: bool

## For rotation tweening...
var initial_camera_position: Vector3
var target_position: Vector3

var elapsed_sec: float = 0.0

var tw: Tween

func _init() -> void:
	if not OS.is_debug_build() or debug_mesh: return
	debug_mesh = MeshInstance3D.new()
	debug_mesh.top_level = true
	add_child(debug_mesh)
	debug_mesh.mesh = SphereMesh.new() as SphereMesh
	debug_mesh.mesh.height = 0.04
	debug_mesh.mesh.radius = debug_mesh.mesh.height / 2.0
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.no_depth_test = true
	material.depth_draw_mode = BaseMaterial3D.DEPTH_DRAW_ALWAYS
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_color = Color(1.0, 0.0, 1.0, 0.6)
	debug_mesh.mesh.material = material
	debug_mesh.visible = false

#func interpolate(from: Variant, to: Variant, duration: float, transition_type: Tween.TransitionType, ease_type: Tween.EaseType) -> Variant:
	#return Tween.interpolate_value(from, to - from, tw_elapsed_sec, duration, transition_type, ease_type)

func get_camera_pitch() -> float:
	return camera.rotation.x

func set_camera_pitch(pitch: float) -> void:
	camera.rotation.x = clampf(pitch, -MAX_PITCH, MAX_PITCH)

func look_toward(point: Vector3, duration_sec: float = DEFAULT_DURATION_SEC) -> void:
	var pos_delta: Vector3 = point - camera.global_position
	print("Focusing: %1.1v -> %1.1v" % [camera.global_position, point])
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
	tw.tween_method(set_camera_pitch, get_camera_pitch(), target_pitch, duration_sec)
	tw.chain().tween_property(camera, ^"fov", default_fov/zoom, ZOOM_DURATION_SEC)
	
	if debug_mesh and debug: 
		debug_mesh.visible = true
		debug_mesh.global_position = point 

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint() or not focus_active: return
	elapsed_sec += delta
	_update_follow(delta)


func _update_follow(delta: float) -> void:
	if target_position == focused_node.global_position and camera.global_position == initial_camera_position: 
		return # No need to update anything if neither position changed...
	
	if focused_node:
		target_position = focused_node.global_position
	initial_camera_position = camera.global_position
	
	look_toward(target_position, DEFAULT_DURATION_SEC)
	tw.custom_step(elapsed_sec) # Custom step to immediately interpolate.

func focus(node_3d: Node3D) -> void:
	elapsed_sec = 0.0
	focused_node = node_3d
	focus_active = (node_3d != null)
	set_physics_process(focus_active)
	initial_camera_position = Vector3()
	target_position = Vector3()


func focus_zoom(node_3d: Node3D, zoom_level: float = 1.0) -> void:
	focus(node_3d)
	set_zoom(zoom_level)

func release_focus() -> void:
	focus(null)
	focus_active = false
	if tw and tw.is_valid():
		tw.kill()

func set_zoom(val: float) -> void:
	if zoom == val: return
	zoom = val
	if not Engine.is_editor_hint() and camera:
		if tw and tw.is_running():
			tw.tween_property(camera, ^"fov", default_fov/zoom, ZOOM_DURATION_SEC)
		else:
			create_tween().tween_property(camera, ^"fov", default_fov/zoom, ZOOM_DURATION_SEC).set_delay(0.2 if tw and tw.is_running() else 0.0)

func reset_zoom() -> void:
	zoom = 1.0

## Releases focus and resets zoom.
func release_all() -> void:
	release_focus()
	reset_zoom()
	set_indexed(^"debug_mesh:visible", false)

func set_debug(val: bool) -> void:
	debug = val
	set_indexed(^"debug_mesh:visible", debug)

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_ENTER_TREE when not Engine.is_editor_hint():	# Reapply on enter tree due to HTML5 glitch.
			get_parent().set_meta(&"CameraAction", self) 
		NOTIFICATION_PARENTED:
			get_parent().set_meta(&"CameraAction", self)
		NOTIFICATION_UNPARENTED:
			get_parent().set_meta(&"CameraAction", null)
		
		NOTIFICATION_EDITOR_PRE_SAVE: 							# Remove meta before save (prevents recursion issues)
			get_parent().set_meta(&"CameraAction", null)
		NOTIFICATION_EDITOR_POST_SAVE:
			get_parent().set_meta(&"CameraAction", self)
