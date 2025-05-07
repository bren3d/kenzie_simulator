@icon("res://assets/icons/icon_interrogation.png")
@tool
class_name Interactable extends Component
const COLLISION_LAYER: int = 3

const OUTLINE_MATERIAL: ShaderMaterial = preload("res://resources/materials/outline.tres")

#static var hovered_object: Node
static var active_interactable: Node

## [param interactor] refers to the entity that began this interaction.
signal interaction_started(interactor: Object)
signal interaction_ended

@export var collider_body: CollisionObject3D : set = set_collider_body
@export var mesh: MeshInstance3D

@export_range(0.0, 5.0, 0.1, "or_greater", "suffix:m")
var max_interaction_distance: float = 1.5

@export_placeholder("Use") 
var interaction_text: String

## Immediately ends interaction after starting. Useful for instant actions that do not need to block player input.
@export var auto_end_interaction: bool = true

var is_hovered: bool = false: set = set_is_hovered
var active: bool = false

## Call to start interaction. Overwrite for custom behavior.
func start_interaction(interactor: Object = null) -> void:
	active = true
	active_interactable = get_parent()
	interaction_started.emit(interactor)
	if auto_end_interaction:
		end_interaction()

## Call to exit interaction. Overwrite for custom behavior.
func end_interaction() -> void:
	active = false
	if active_interactable == get_parent():
		active_interactable = null
	interaction_ended.emit()

func set_is_hovered(val: bool) -> void:
	is_hovered = val
	if mesh:		mesh.material_overlay = OUTLINE_MATERIAL if is_hovered else null

func set_collider_body(val: CollisionObject3D) -> void:
	if collider_body == val: return
	collider_body = val
	if not collider_body: return
	collider_body.set_collision_layer_value(COLLISION_LAYER, true)
	if not Engine.is_editor_hint():
		collider_body.set_meta(get_tag(), self)

func get_interaction_text() -> String:
	return interaction_text
