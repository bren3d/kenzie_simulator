@tool
class_name CameraShaker extends Node
## Shakes the current camera by moving its position.

## How long the shaking lasts.
@export_range(0.0, 10.0, 0.1, "suffix:s", "or_greater") 
var duration_sec: float = 1.0

## How far the shaking can move the camera in each direction.
@export_range(0.0, 10.0, 0.1, "suffix:m", "or_greater") 
var magnitude: float = 0.2

var camera: Camera3D
var initial_position: Vector3
var elapsed_time_sec: float = 0.0

func _ready() -> void:
	set_physics_process(false)

func shake_camera():
	elapsed_time_sec = 0.0
	camera = get_viewport().get_camera_3d()
	initial_position = camera.position
	set_physics_process(true)

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint() or not camera: return
	elapsed_time_sec += delta
	
	if elapsed_time_sec >= duration_sec:
		camera.position = initial_position
		camera = null
		set_physics_process.call_deferred(false)
		return
	
	var offset = Vector3( randf_range(-magnitude, magnitude), randf_range(-magnitude, magnitude), 0.0)
	camera.position = initial_position + offset
