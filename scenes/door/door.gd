@icon("res://assets/icons/icon_door.png")
@tool
class_name Door extends Node3D

const HANDLE_ROTATION_RADS: float = deg_to_rad(-60.0)

signal group_changed

signal opened
signal closed

signal door_locked
signal door_unlocked

@export_tool_button("Toggle Open/Closed", "MoveUp") 
var toggle_callable: Callable = toggle

@export_storage var open: bool: set = set_open, get = is_open

@export var locked: bool: set = set_locked

@export var group: DoorGroup:
	set(val):
		if group: 	group.remove_door(self)
		group = val
		if group: 	group.add_door(self)

@export_placeholder("Locked...") 
var locked_dialogue_text: String = "It's locked..."

@export_group("Animation")

@export var disable_animation: bool:
	set(val):
		disable_animation = val
		notify_property_list_changed()

@export var opens_forward: bool = true

@export_range(40.0, 180.0, 5.0, "radians_as_degrees") 
var max_rotation: float = PI/1.6:
	set(val):
		max_rotation = val
		$Hinge.rotation.y = get_target_rotation()

@export_subgroup("Tween Properties")

@export_range(0.0, 2.0, 0.05, "or_greater", "suffix:s") var tween_duration_sec: float = 0.6
@export var tween_trans: Tween.TransitionType = Tween.TRANS_ELASTIC
@export var tween_ease: Tween.EaseType = Tween.EASE_IN_OUT

func interact(interactor: Object = null) -> void:
	# TODO - add unlock check/action
	pass
	

func toggle(interactor: Object = null) -> void:
	if locked:
		animate_locked()
		return
	
	open = !is_open()

func _update_group() -> void:
	if not group: return
	set_block_signals(true)
	group.update(self)
	set_block_signals(false)

#func attempt_unlock(interactor: Object = null) -> void:
	## TODO - add unlock check
	#
	#print("Cannot toggle door open/closed while it is locked.")
	#if locked_dialogue_text and interactor and interactor.has_method(&"show_message"):
		#interactor.call(&"show_message", locked_dialogue_text)

## Played when trying to enter locked door
func animate_locked() -> void:
	
	# TODO - Play locked sound
	
	const LOCKED_ANIMATION_DURATION_SEC: float = 0.4
	const LOCKED_ROTATION_RADS: float = HANDLE_ROTATION_RADS / 5.0
	var handles: Node3D = $Hinge/DoorMesh/HandleStemMesh/Handles
	var tw:= create_tween()
	tw.tween_property(handles, ^"rotation:y", LOCKED_ROTATION_RADS, LOCKED_ANIMATION_DURATION_SEC/4.0)
	tw.tween_property(handles, ^"rotation:y", 0.0, LOCKED_ANIMATION_DURATION_SEC/4.0)
	tw.tween_property(handles, ^"rotation:y", LOCKED_ROTATION_RADS, LOCKED_ANIMATION_DURATION_SEC/4.0)
	tw.tween_property(handles, ^"rotation:y", 0.0, LOCKED_ANIMATION_DURATION_SEC/4.0)
	


func set_open(val: bool) -> void:
	if open == val: return
	
	open = val
	$Hinge/StaticBody3D.set_collision_layer_value(1, not open or disable_animation)
	
	_update_interactable_text()
	
	if not disable_animation:
		animate_open_close.call_deferred()
	
	if open:
		opened.emit()  
	else:
		closed.emit()
	
	_update_group()
	

func is_open() -> bool:
	return open

func set_locked(val: bool) -> void:
	if locked == val: return
	
	locked = val
	
	if locked:
		door_locked.emit()
	else:
		door_unlocked.emit()
	
	_update_group()

func animate_open_close() -> void:
	var tw:= create_tween().set_trans(tween_trans).set_ease(tween_ease).set_parallel()
	tw.tween_property($Hinge, ^"rotation:y", get_target_rotation(), tween_duration_sec)
	tw.tween_property($Hinge/DoorMesh/HandleStemMesh/Handles, ^"rotation:y", HANDLE_ROTATION_RADS, tween_duration_sec/4.0)
	tw.chain().tween_property($Hinge/DoorMesh/HandleStemMesh/Handles, ^"rotation:y", 0.0, tween_duration_sec/4.0)

func get_target_rotation() -> float:
	return (-1.0 + 2.0 * float(opens_forward))*(max_rotation)*float(open)

func _update_interactable_text() -> void:
	if not has_node(^"Interactable"): return
	var interactable:= get_node(^"Interactable")
	if locked:
		interactable.set(&"interaction_text", "locked")
		return
	interactable.set(&"interaction_text", "close" if open else "open")

func get_interaction_text() -> String:
	if locked:
		return "locked"
	if disable_animation:
		return "enter"
	if open:
		return "close"
	return "open"

func _validate_property(property: Dictionary) -> void:
	if not disable_animation: return
	match property.name:
		"opens_forward", "max_rotation", "Tween Properties", "tween_duration_sec", "tween_trans", "tween_ease": 
			property.usage &= ~(PROPERTY_USAGE_EDITOR)
