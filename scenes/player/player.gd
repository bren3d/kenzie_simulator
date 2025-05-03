@tool
class_name Player extends CharacterBody3D

const RUN_SPEED_MULT: float = 1.5
const DEFAULT_SPEED: float = 5.0

const JUMP_VELOCITY: float = 4.5
const ACCELERATION: float = 30.0

const MAX_PITCH: float = PI / 2.025

var speed_mult: float = 1.0
var speed: float = DEFAULT_SPEED

@export_range(0.05, 10.0, 0.05, "or_greater", "exp" ) 
var camera_sensitivity: float = 2.0

@onready var state_machine: StateMachine = $StateMachine
@onready var camera: Camera3D = $Camera3D
@onready var interact_ray: InteractRay = $Camera3D/InteractRay

var input_active: bool = true: set = set_input_active
var camera_active: bool = true

var sprinting: bool = false
var input_dir: Vector2 = Vector2.ZERO

var can_interact: bool = true

func _ready() -> void:
	if Engine.is_editor_hint(): return
	create_tween().tween_callback(set_flashlight_active.bind(false)).set_delay(0.1)

func _process(delta: float) -> void:
	state_machine.update_process(delta)

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	state_machine.update_physics_process(delta)

func _input(event: InputEvent) -> void:
	state_machine.on_input(event)

func _unhandled_input(event: InputEvent) -> void:
	state_machine.on_unhandled_input(event)

func _mouse_enter() -> void:
	state_machine.on_mouse_entered()

func _mouse_exit() -> void:
	state_machine.on_mouse_exited()

## Moves camera based on given input event.
func move_camera(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotation.y -= event.relative.x / 1000 * camera_sensitivity
		if camera: 
			camera.rotation.x -= event.relative.y / 1000 * camera_sensitivity
		
		rotation.x = clamp(rotation.x, -MAX_PITCH, MAX_PITCH)
		if camera:
			camera.rotation.x = clampf(camera.rotation.x, -MAX_PITCH, MAX_PITCH)

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
