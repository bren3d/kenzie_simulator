@icon("res://assets/icons/icon_door.png")
@tool
class_name Door extends Node3D

const SLAM_SOUND_DELAY_SEC: float = 0.4
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

@export var mute_sounds: bool = false
@export var slam_door_on_close: bool = false
@export_group("Audio")
@export var open_sound: AudioStream
@export var close_sound: AudioStream
@export var locked_sound: AudioStream
@export var slam_sound: AudioStream

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
@export_range(0.0, 1.0, 0.05, "or_greater", "suffix:s") var slam_duration_sec: float = 0.25


func toggle(interactor: Object = null) -> void:
	if locked:
		animate_locked()
		return
	
	if slam_door_on_close and open:
		slam_door()
	else:
		open = !is_open()

func _update_group() -> void:
	if not group: return
	set_block_signals(true)
	group.update(self)
	set_block_signals(false)

## Played when trying to enter locked door
func animate_locked() -> void:
	
	play_sound(locked_sound)
	
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
		if not mute_sounds:
			play_sound(open_sound)
		opened.emit()
	else:
		if not slam_door_on_close and not mute_sounds:
			play_sound(close_sound)
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

func play_sound(audio_stream: AudioStream) -> void:
	if not is_node_ready(): return
	var player: AudioStreamPlayer3D = $AudioStreamPlayer3D
	player.stream = audio_stream
	player.play()

func play_slam() -> void:
	play_sound(slam_sound)

func slam_door() -> void:
	if not open or disable_animation:
		push_warning("Cannot slam closed or animation disabled door.")
		return
	
	disable_animation = true
	set_open(false)
	disable_animation = false
	
	var tw:= create_tween().set_parallel()
	tw.tween_property($Hinge, ^"rotation:y", get_target_rotation(), slam_duration_sec)
	if not mute_sounds:
		tw.tween_callback(play_sound.bind(slam_sound))

func _validate_property(property: Dictionary) -> void:
	if not disable_animation: return
	match property.name:
		"opens_forward", "max_rotation", "Tween Properties", "tween_duration_sec", "tween_trans", "tween_ease": 
			property.usage &= ~(PROPERTY_USAGE_EDITOR)
