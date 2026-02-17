@tool
extends CatState

@export_range(0.01, 2.0, 0.01, "suffix:s") var recover_time_sec: float = 0.6
@export var next_state_name: StringName = &"wander"

var initial_rotation: Vector3 = Vector3.ZERO
var current_recover_time: float = 0.0

func _init() -> void:
	name = &"recover"

func enter() -> void:
	cat.freeze = true
	initial_rotation = cat.global_rotation
	current_recover_time = 0.0

func exit() -> void:
	cat.freeze = false

func update_physics_process(delta: float) -> void:
	current_recover_time += delta
	var t: float = minf(1.0, current_recover_time/(recover_time_sec))
	cat.global_rotation = initial_rotation.slerp(Vector3.ZERO, t)
	if cat.global_position.y < 0.0:
		cat.global_position.y = lerpf(cat.global_position.y, 0.0, t)
	
	if t >= 1.0:
		transition_requested.emit(next_state_name)
