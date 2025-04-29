@tool
extends PlayerState

const GODMODE_SPEED: float = 10.0
const SPRINT_SPEEDUP: float = 2.0

var active: bool = false

func _init() -> void:
	name = &"Godmode"

func enter() -> void:
	active = true
	player.input_active = true
	player.input_dir = Input.get_vector(&"left", &"right", &"up", &"down")

func exit() -> void:
	active = false
	player.velocity = Vector3.ZERO
	player.input_active = false
	player.input_dir = Vector2.ZERO

func update_physics_process(delta: float) -> void:
	var basis: Basis = get_viewport().get_camera_3d().global_transform.basis
	var direction: Vector3 = basis * Vector3(player.input_dir.x, float(Input.is_action_pressed(&"jump")) - float(Input.is_key_pressed(KEY_CTRL)), player.input_dir.y)
	var position_delta: float = GODMODE_SPEED * delta * (1.0 + float(Input.is_action_pressed(&"sprint")) * SPRINT_SPEEDUP)
	player.position += direction * position_delta

func on_input(event: InputEvent) -> void:
	player.move_camera(event)
	if event.is_action(&"up") or event.is_action(&"down") or event.is_action(&"left") or event.is_action(&"right"):
		player.input_dir = Input.get_vector(&"left", &"right", &"up", &"down")
		get_viewport().set_input_as_handled()

func on_unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"flashlight"):
		player.toggle_flashlight()
		get_viewport().set_input_as_handled()

func _unhandled_input(event: InputEvent) -> void:
	if OS.is_debug_build() and event is InputEventKey and event.is_pressed() and not event.is_echo() and event.keycode == KEY_G:
		transition_requested.emit("Moving" if active else name)
		get_viewport().set_input_as_handled()
	
