@icon("res://assets/icons/icon_door.png")
@tool
class_name Door extends Node3D

const HANDLE_ROTATION_RADS: float = deg_to_rad(-60.0)

signal opened
signal closed

signal door_locked
signal door_unlocked

@export_tool_button("Toggle Open/Closed", "MoveUp") 
var toggle_callable: Callable = toggle

@export var open: bool: set = set_open, get = is_open

@export var locked: bool: set = set_locked

@export var synced_door: Door:
	set(val):
		var previous_door: Door = synced_door
		synced_door = val
		if previous_door and previous_door != synced_door and previous_door.synced_door == self:
			previous_door.synced_door = null
		if synced_door and synced_door.synced_door != self:
			synced_door.synced_door = self
			synced_door.set_open(open)
			synced_door.set_locked(locked)

@export_placeholder("Locked...") var locked_dialogue_text: String = "It's locked..."

@export_group("Animation")

@export var disable_animation: bool:
	set(val):
		disable_animation = val
		notify_property_list_changed()

@export var opens_forward: bool = true
@export_range(40.0, 180.0, 5.0, "radians_as_degrees") 
var max_rotation: float = PI/1.6

@export_subgroup("Tween Properties")

@export_range(0.0, 2.0, 0.05, "or_greater", "suffix:s") var tween_duration_sec: float = 0.6
@export var tween_trans: Tween.TransitionType = Tween.TRANS_ELASTIC
@export var tween_ease: Tween.EaseType = Tween.EASE_IN_OUT

func toggle() -> void:
	if locked:
		show_locked_dialogue()
		return
	
	open = !is_open()

func show_locked_dialogue() -> void:
	if Engine.is_editor_hint() or not locked_dialogue_text: return
	
	DialogueManager.show_dialogue_balloon(DialogueManager.create_resource_from_text(tr(locked_dialogue_text)))

func set_open(val: bool) -> void:
	if open == val: return
	
	open = val
	$Hinge/StaticBody3D.set_collision_layer_value(1, not open or disable_animation)
	
	_update_interactable_text()
	
	if not disable_animation:
		_animate.call_deferred()

	if synced_door:
		synced_door.set_open(open)
	
	if open:
		opened.emit()  
	else:
		closed.emit()

func is_open() -> bool:
	return open

func set_locked(val: bool) -> void:
	if locked == val: return
		
	locked = val
	if synced_door:
		synced_door.set_locked(locked)
	
	if locked:
		door_locked.emit()
	else:
		door_unlocked.emit()

func _animate() -> void:
	var tw:= create_tween().set_trans(tween_trans).set_ease(tween_ease).set_parallel()
	tw.tween_property($Hinge, ^"rotation:y", (-1.0 + 2.0 * float(opens_forward))*(max_rotation)*float(open), tween_duration_sec)
	tw.tween_property($Hinge/DoorMesh/HandleStemMesh/Handles, ^"rotation:y", HANDLE_ROTATION_RADS, tween_duration_sec/4.0)
	tw.chain().tween_property($Hinge/DoorMesh/HandleStemMesh/Handles, ^"rotation:y", 0.0, tween_duration_sec/4.0)

func _update_interactable_text() -> void:
	if not has_node(^"Interactable"): return
	var interactable: Interactable = get_node(^"Interactable")
	if locked:
		interactable.interaction_text = "locked"
		return
	interactable.interaction_text = "close" if open else "open"

func _validate_property(property: Dictionary) -> void:
	if not disable_animation: return
	match property.name:
		"opens_forward", "max_rotation", "Tween Properties", "tween_duration_sec", "tween_trans", "tween_ease": 
			property.usage &= ~(PROPERTY_USAGE_EDITOR)

func _get_property_list() -> Array[Dictionary]:
	var props: Array[Dictionary]
	if has_node(^"Interactable"):
		for dict: Dictionary in $Interactable.get_property_list():
			if dict.name in ["interactable.gd", "interaction_text", "overlay_material", "auto_end_interaction"]:
				props.push_back(dict)
	return props

func _set(property: StringName, value: Variant) -> bool:
	if property in ["interaction_text", "overlay_material", "auto_end_interaction"] and has_node(^"Interactable"):
		$Interactable.set(property, value)
		return true
	return false

func _get(property: StringName) -> Variant:
	return $Interactable.get(property) if property in ["interaction_text", "overlay_material", "auto_end_interaction"] and has_node(^"Interactable") else null
