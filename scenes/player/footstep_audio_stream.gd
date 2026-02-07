class_name FootstepAudioStream extends AudioStreamPlayer

const FOOTSTEP_META_TAG: StringName = &"footstep"

@export var player_collider: Player
@export var floor_raycast: RayCast3D
@export var default_stream: AudioStream

@export var pitch_delta_max: float = 0.25

@export var max_velocity: float = 5.0

@export var max_delay_sec: float = 3.0
@export var min_delay_sec: float = 0.5

var current_delay_sec: float = 5.0

func _ready() -> void:
	if Engine.is_editor_hint(): return


func _physics_process(delta: float) -> void:
	current_delay_sec += delta
	if not player_collider.is_on_floor() or not player_collider.input_dir:
		return
	
	#print()
	#var velocity_
	if get_velocity_delay_duration_sec() <= current_delay_sec:
		play_footstep(get_floor_audio_stream())
		current_delay_sec = 0.0


func play_footstep(footstep_stream: AudioStream) -> void:
	stream = footstep_stream
	pitch_scale = 1.0 + lerpf(-pitch_delta_max, pitch_delta_max, randf())
	play()

func get_velocity_delay_duration_sec() -> float:
	var effective_velocity: float = minf(player_collider.get_real_velocity().length(), max_velocity)
	var t: float = inverse_lerp(0.0, max_velocity, effective_velocity)
	var result: float = lerpf(max_delay_sec, min_delay_sec, t)
	return result

func get_floor_audio_stream() -> AudioStream:
	if not floor_raycast.is_colliding(): 
		return default_stream
	return floor_raycast.get_collider().get_meta(FOOTSTEP_META_TAG, default_stream)
