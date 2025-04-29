@tool
class_name Interactable extends Component
const COLLISION_LAYER: int = 3

static var hovered_object: Object

signal interaction_started
signal interaction_ended

@export 
var collider_body: CollisionObject3D : set = set_collider_body

@export var auto_end: bool = false

@export_range(0.0, 5.0, 0.1, "or_greater", "suffix:m")
var max_interaction_distance: float = 1.5

@export_placeholder("Eat/Drink/etc.") 
var interaction_text: String = ""

var active: bool = false : set = set_active

#static func _static_init() -> void:
	#Engine.add_user_signal("hover_started")

## Call to start interaction. Overwrite for custom behavior.
func start_interaction() -> void:
	if active: return
	active = true
	interaction_started.emit()
	if auto_end:
		end_interaction()

## Call to exit interaction. Overwrite for custom behavior.
func end_interaction() -> void:
	if not active: return
	active = false
	interaction_ended.emit()

func set_collider_body(val: CollisionObject3D) -> void:
	if collider_body == val: return
	collider_body = val
	if not collider_body: return
	collider_body.input_ray_pickable = true
	collider_body.input_capture_on_drag = true
	collider_body.set_collision_layer_value(COLLISION_LAYER, true)
	collider_body.mouse_entered.connect(_on_mouse_enter)
	collider_body.mouse_exited.connect(_on_mouse_exit)
	collider_body.input_event.connect(_on_input_event)

func _on_mouse_enter() -> void:
	hovered_object = get_parent()

func _on_mouse_exit() -> void:
	if hovered_object == get_parent():
		hovered_object = null

func _on_input_event(camera: Camera3D, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if is_interactable(camera, event, event_position) and event.is_action_pressed(&"interact"):
		pass

func is_interactable(camera: Camera3D, event: InputEvent, event_position: Vector3) -> bool:
	return camera.global_position.distance_to(event_position) <= max_interaction_distance 

func get_interaction_text() -> String:
	return interaction_text

func get_tag() -> StringName:
	return &"Interactable"

func set_active(val: bool) -> void:
	active = val
