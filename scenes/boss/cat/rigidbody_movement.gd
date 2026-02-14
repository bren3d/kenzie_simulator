@tool
class_name RigidBodyMovement extends Node

const DISTANCE_THRESHOLD_SQUARED: float = 0.05

signal movement_started
signal movement_finished

@onready var host: RigidBody3D = get_parent()

@export var active: bool = false: set = set_active

@export_range(30.0, 720.0, 10.0, "suffix:°/s", "radians_as_degrees") 
var turn_speed_rads_sec: float = PI

@export_range(0.1, 10.0, 0.1, "suffix:m/s")
var move_speed: float = 2.0

@export var target_global_position: Vector3: set = set_target


func _physics_process(delta: float) -> void:
	if not active or Engine.is_editor_hint(): return
	
	if host.global_position.distance_squared_to(target_global_position) < DISTANCE_THRESHOLD_SQUARED: 
		host.linear_velocity = Vector3.ZERO
		active = false
		movement_finished.emit()
		return
	
	var dir: Vector3 = (target_global_position - host.global_position).normalized()
	var target_y_angle: float = atan2(dir.x, dir.z) 
	
	host.global_rotation.y = lerp_angle(host.global_rotation.y, target_y_angle, turn_speed_rads_sec * delta)
	host.linear_velocity = dir * move_speed


func set_target(global_pos: Vector3) -> void:
	target_global_position = global_pos
	active = true
	movement_started.emit()

func set_active(val: bool) -> void:
	active = val
	if Engine.is_editor_hint() or not host: return
	host.lock_rotation = val
