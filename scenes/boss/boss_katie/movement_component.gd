@tool
class_name MovementComponent3D extends Node

const DISTANCE_THRESHOLD_SQUARED: float = 0.05

signal move_speed_changed(new_move_speed: float)

signal started
signal finished

@onready var host: Node3D = get_parent()

@export var active: bool = false

@export_range(30.0, 720.0, 10.0, "suffix:°/s", "radians_as_degrees") 
var turn_speed_rads_sec: float = PI

@export_range(0.0, 10.0, 0.1, "suffix:m/s", "or_greater") 
var move_speed: float = 1.0: set = set_move_speed

var target_position: Vector3: set = set_target_position

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint() or not active: return
	
	if host.global_position.distance_squared_to(target_position) < DISTANCE_THRESHOLD_SQUARED: 
		active = false
		finished.emit()
		return
	
	var dir: Vector3 = (target_position - host.global_position).normalized()
	var target_y_angle: float = atan2(dir.x, dir.z) 
	
	# TODO: account for being upside down
	host.global_rotation.y = lerp_angle(host.global_rotation.y, target_y_angle, turn_speed_rads_sec * delta)
	host.global_position = host.global_position.move_toward(target_position, move_speed)

func set_move_speed(val: float) -> void:
	move_speed = val
	move_speed_changed.emit()


func set_target_position(val: Vector3) -> void:
	target_position = val
	active = true
	started.emit()
