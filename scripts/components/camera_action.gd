@icon("res://assets/icons/icon_camera_grid.png")
@tool
class_name CameraAction extends Marker3D

signal focused

@export_range(0.2, 3.0, 0.1, "or_greater")
var zoom: float = 1.0

@export_range(1.0, 1000.0, 0.5, "or_greater", "radians_as_degrees")
var speed_rads: float = PI

@export_range(0.1, 10.0, 0.1)
var zoom_speed: float = 1.0

var player: Player

func _ready() -> void:
	set_physics_process(false)

func is_focused() -> bool:
	return is_physics_processing()

func focus() -> void:
	player = get_viewport().get_camera_3d().get_parent()
	player.camera_controller.focus(global_position)
	#set_physics_process(true)
	#player = get_viewport().get_camera_3d().get_parent()
	#create_tween().tween_callback(emit_signal.bind(&"focused"))\
	#.set_delay(0.3)

func release_focus() -> void:
	player.clear_camera_zoom()
	set_physics_process(false)

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	
	var pos_delta: Vector3 = global_position - player.camera.global_position
	
	var yaw: float = atan2( -pos_delta.x, -pos_delta.z,)
	
	var pitch: float = atan2(pos_delta.y, Vector2(pos_delta.x, pos_delta.z).length(),)
	
	
	player.rotation.y = rotate_toward(player.rotation.y, yaw, speed_rads * delta)
	player.set_camera_pitch(rotate_toward(player.get_camera_pitch(), pitch, speed_rads * delta))
	
	
	if angle_difference(yaw, player.rotation.y) == 0.0  and angle_difference(player.get_camera_pitch(), pitch) == 0.0:
		player.camera.fov = move_toward(player.camera.fov, player.default_fov/zoom, delta * zoom_speed)
