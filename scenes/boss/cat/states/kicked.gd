@tool
extends CatState

const MIN_KICK_DURATION_SEC: float = 0.1
const LINEAR_VELOCITY_DESPAWN_LIMIT_SQUARED: float = 0.05

const MIN_LIFT: float = 0.0
const MAX_PITCH_THRESHOLD: float = PI/2.8
const MAX_TORQUE_IMPULSE: float = PI/2.0

const TORQUE_IMPULSE_DELAY_SEC: float = 0.1

@export_range(5.0, 50.0, 0.5, "or_greater") var kick_power: float = 25.0 
@export_range(0.0, 30.0, 0.25, "or_greater") var max_lift: float = 15.0

@export var cat_screams: Array[AudioStream]

@export_range(0.0, 30.0, 0.5, "suffix:s") var timeout_sec: float = 7.5

@export var next_state_name: StringName = &"explode"

var current_timeout_timer: float = 0.0

func _init() -> void:
	name = &"kicked"

func enter() -> void:
	cat.kickable = false
	current_timeout_timer = 0.0
	kick()

func kick() -> void:
	var dir: Vector3 = (-Global.player.basis.z * Vector3(1,0,1)).normalized()
	var lift_t: float = inverse_lerp(-MAX_PITCH_THRESHOLD, MAX_PITCH_THRESHOLD, clampf(Global.player.get_camera_pitch(), -MAX_PITCH_THRESHOLD, MAX_PITCH_THRESHOLD))
	var lift_vector: Vector3 = (Vector3.UP * lerpf(MIN_LIFT, max_lift, lift_t))
	
	var impulse: Vector3 = dir * 10.0 + lift_vector
	cat.apply_central_impulse(impulse)
	cat.play_sound(cat_screams.pick_random())
	create_tween().tween_callback(cat.apply_torque_impulse.bind(get_random_torque())).set_delay(TORQUE_IMPULSE_DELAY_SEC)

func get_random_torque() -> Vector3:
	return (Vector3(randf(), randf(), randf()) * MAX_TORQUE_IMPULSE).limit_length(MAX_TORQUE_IMPULSE)

func update_physics_process(delta: float) -> void:
	current_timeout_timer += delta
	if current_timeout_timer < MIN_KICK_DURATION_SEC: return
	if cat.linear_velocity.length_squared() < LINEAR_VELOCITY_DESPAWN_LIMIT_SQUARED or current_timeout_timer >= timeout_sec:
		transition_requested.emit(next_state_name)
