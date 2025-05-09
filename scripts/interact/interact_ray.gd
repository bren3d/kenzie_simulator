@tool
class_name InteractRay extends RayCast3D
const INTERACTION_LAYER: int = 3

signal hover_changed(obj: Object)

@export var interaction_label: Label

var hovered_interactable: Interactable:
	set(val):
		if hovered_interactable == val: return
		
		if hovered_interactable and not val:
			hovered_interactable.set_is_hovered(false)
		
		hovered_interactable = val
		
		if hovered_interactable:
			hovered_interactable.set_is_hovered(true)
		
		if interaction_label:
			interaction_label.text = hovered_interactable.get_interaction_text() if val else ""
		
		hover_changed.emit(hovered_interactable.get_parent() if val else null)

func _init() -> void:
	collide_with_areas = true
	target_position = Vector3.FORWARD * 4096
	collision_mask |= Interactable.COLLISION_LAYER

func _ready() -> void:
	if interaction_label:
		interaction_label.text = ""
		if not Engine.is_editor_hint():
			DialogueManager.dialogue_started.connect(interaction_label.hide.unbind(1))
			DialogueManager.dialogue_ended.connect(interaction_label.show.unbind(1))

func _physics_process(delta: float) -> void:
	var collider:= get_collider()
	var interactable: Interactable = collider.get_meta(&"Interactable") if collider and collider.has_meta(&"Interactable") else null
	if interactable == hovered_interactable:
		if interactable:
			interaction_label.text = interactable.get_interaction_text()
		return
	
	if interactable and global_position.distance_squared_to(get_collision_point()) > interactable.max_interaction_distance ** 2:
		interactable = null
	
	hovered_interactable = interactable

func can_interact() -> bool:
	return hovered_interactable != null
