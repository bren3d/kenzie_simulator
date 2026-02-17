@tool
extends CatState

@export_range(0.0, 10.0, 0.1, "suffix:s")
var wander_timeout_sec: float = 7.5 

@export_range(0.0, 10.0, 0.5, "suffix:m")
var min_wander_distance: float = 1.0
@export_range(0.0, 10.0, 0.5, "suffix:m")
var max_wander_distance: float = 4.0

@export_range(0.0, 10.0, 0.1, "suffix:s")
var min_wander_delay_sec: float = 0.0

@export_range(0.0, 10.0, 0.1, "suffix:s")
var max_wander_delay_sec: float = 3.0

var wander_delay_time_sec: float = 1.0

var current_task_time_sec: float = 0.0

func _init() -> void:
	name = &"wander"

func enter() -> void:
	cat.kickable = true
	start_wander()
	cat.movement.movement_finished.connect(_on_movement_finished)

func exit() -> void:
	current_task_time_sec = 0.0
	if cat.movement.movement_finished.is_connected(_on_movement_finished):
		cat.movement.movement_finished.disconnect(_on_movement_finished)
	cat.movement.stop()

func start_wander() -> void:
	current_task_time_sec = 0.0
	cat.movement.set_target(get_random_target())

func stop_wander() -> void:
	wander_delay_time_sec = get_random_delay()
	current_task_time_sec = 0.0

func update_physics_process(delta: float) -> void:
	current_task_time_sec += delta
	if cat.movement.active:
		if current_task_time_sec >= max_wander_distance:
			cat.movement.stop()
	elif current_task_time_sec >= wander_delay_time_sec:
		start_wander()

func _on_movement_finished() -> void:
	stop_wander()

func get_random_target() -> Vector3:
	var angle: float = randf() * TAU
	var dir_vec: Vector3 = Vector3(cos(angle), 0.0, sin(angle)) 
	var magnitude: float = randf_range(min_wander_distance, max_wander_distance)
	return dir_vec * magnitude

func get_random_delay() -> float:
	return randf_range(min_wander_delay_sec, max_wander_delay_sec)

func on_unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"kick") and cat.is_kickable():
		cat.movement.stop()
		transition_requested.emit(&"kicked")
		get_viewport().set_input_as_handled()
