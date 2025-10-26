@tool
class_name Player extends CharacterBody3D

const RUN_SPEED_MULT: float = 1.5
const DEFAULT_SPEED: float = 5.0

const JUMP_VELOCITY: float = 4.5
const ACCELERATION: float = 30.0

const MAX_PITCH: float = PI / 2.025
const YAW_SPEED_RADS_PER_SEC: float = TAU * 1.0
const PITCH_SPEED_RADS_PER_SEC: float = PI
const ROTATION_DURATION_SEC: float = 0.4
const ZOOM_DURATION_SEC: float = 0.2

var speed_mult: float = 1.0
var speed: float = DEFAULT_SPEED

@export_range(0.05, 10.0, 0.05, "or_greater", "exp" ) 
var camera_sensitivity: float = 0.7

@onready var state_machine: StateMachine = $StateMachine
@onready var camera: Camera3D = $Camera3D
@onready var camera_controller: CameraController = $CameraController
@onready var default_fov: float = camera.fov
@onready var interact_ray: InteractRay = $Camera3D/InteractRay

var input_active: bool = true: set = set_input_active
var camera_active: bool = true

var sprinting: bool = false
var input_dir: Vector2 = Vector2.ZERO

var can_interact: bool = true
var can_cough: bool = true

var can_die: bool = true

func _ready() -> void:
	if Engine.is_editor_hint(): return
	
	show_message("")
	
	set_flashlight_active.bind(false)
	$cough.set_paused(false)
	$soda.set_paused(false)
	
	# ALERT 
	can_die = not OS.is_debug_build()
	
	# Turn on to get rid of stutter when loading...
	set_flashlight_active(true)
	create_tween().tween_callback(set_flashlight_active.bind(false)).set_delay(0.2)

func _process(delta: float) -> void:
	state_machine.update_process(delta)

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	state_machine.update_physics_process(delta)

func _input(event: InputEvent) -> void:
	state_machine.on_input(event)

func _unhandled_input(event: InputEvent) -> void:
	state_machine.on_unhandled_input(event)
	if can_cough and event.is_action_pressed(&"cough"):
		cough()

func _mouse_enter() -> void:
	state_machine.on_mouse_entered()

func _mouse_exit() -> void:
	state_machine.on_mouse_exited()

func get_camera_pitch() -> float:
	return camera.rotation.x

func set_camera_pitch(pitch: float) -> void:
	camera.rotation.x = clampf(pitch, -MAX_PITCH, MAX_PITCH)

## Moves camera based on given input event.
func move_camera(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotation.y -= event.screen_relative.x / 1000 * camera_sensitivity
		if camera: 
			set_camera_pitch(camera.rotation.x - event.screen_relative.y / 1000 * camera_sensitivity)

func focus_camera(focus_point: Vector3, zoom: float = 1.0) -> Tween:
	if focus_point == camera.global_position:
		printerr("Cannot focus camera's position, aborting...")
		return null
	
	var pos_delta: Vector3 = focus_point - camera.global_position
	var yaw_delta: float = angle_difference(rotation.y, atan2( -pos_delta.x, -pos_delta.z,))
	var pitch_delta: float = angle_difference(camera.rotation.x, atan2(pos_delta.y, Vector2(pos_delta.x, pos_delta.z).length(),))
	
	var duration_sec: float = maxf(abs(yaw_delta)/YAW_SPEED_RADS_PER_SEC, abs(pitch_delta)/PITCH_SPEED_RADS_PER_SEC)
	
	var tw: Tween = create_tween().set_trans(Tween.TRANS_SINE).set_parallel()
	tw.tween_property(self, ^"rotation:y", rotation.y + yaw_delta, duration_sec)
	tw.tween_property(camera, ^"rotation:x", camera.rotation.x + pitch_delta, duration_sec)
	if zoom != 1.0:
		tw.chain().tween_property(camera, ^"fov", default_fov/zoom, ZOOM_DURATION_SEC)
	
	return tw

func clear_camera_zoom() -> void:
	if camera.fov != default_fov:
		create_tween().tween_property(camera, ^"fov", default_fov, ZOOM_DURATION_SEC)

func is_flashlight_active() -> bool:
	return %Flashlight.visible

func set_flashlight_active(val: bool) -> void:
	%Flashlight.visible = val

func toggle_flashlight() -> void:
	set_flashlight_active(! is_flashlight_active())

func set_state(state_name: String) -> void:
	state_machine.set_state(state_name)

func set_input_active(act: bool) -> void:
	input_active = act

func show_message(text: String) -> void:
	const FADE_IN_OUT_DURATION_SEC: float = 0.4
	%MessageLabel.text = text
	if not text:
		%MessageLabel.modulate.a = 0.0
		return
	var tw: Tween = create_tween().set_trans(Tween.TRANS_SINE)
	tw.tween_property(%MessageLabel as Label, ^"modulate:a", 1.0, FADE_IN_OUT_DURATION_SEC)
	tw.tween_interval(1.5)
	tw.tween_property(%MessageLabel as Label, ^"modulate:a", 0.0, FADE_IN_OUT_DURATION_SEC)

func pause_timers() -> void:
	for child in get_children():
		if child is StatComponent:
			child.pause()

func unpause_timers() -> void:
	for child in get_children():
		if child is StatComponent:
			child.unpause()


func cough() -> void:
	const MIN_COUGH_PITCH_SCALE : float = 0.75
	const MAX_COUGH_PITCH_SCALE: float = 1.5
	$cough.set_value(100.0)
	if not $CoughAudioStream.playing:
		$CoughAudioStream.pitch_scale = lerpf(MIN_COUGH_PITCH_SCALE, MAX_COUGH_PITCH_SCALE, randf())
		$CoughAudioStream.play()

func drink_soda() -> void:
	$soda.set_value(100.0)
	if not $SodaAudioStream.playing:
		$SodaAudioStream.play()

func kill() -> void:
	if not can_die: return
	set_state("Dead")
