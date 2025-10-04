@tool
class_name TriggerProperty extends Component

@export_tool_button("Trigger Action", "Debug")
var action_trigger_callable: Callable = trigger

@export var target_node: Node

@export var property_path: String
@export var value_1: Variant
@export var value_2: Variant

@export var toggle_mode: bool:
	set(val):
		toggle_mode = val
		notify_property_list_changed()

@export var tween_property: bool:
	set(val):
		tween_property = val
		notify_property_list_changed()

@export_group("Tween Properties")
@export var duration: float = 1.0
@export var tw_ease: Tween.EaseType = Tween.EaseType.EASE_IN_OUT
@export var tw_trans: Tween.TransitionType = Tween.TransitionType.TRANS_LINEAR

var is_toggled: bool


func _ready() -> void:
	if Engine.is_editor_hint(): return
	get_parent().get_meta(&"Interactable").interaction_started.connect(trigger)
	
	if not toggle_mode: return
	
	if (value_1 is float and is_equal_approx(target_node.get_indexed(property_path), value_1)):
		is_toggled = false
	elif target_node.get_indexed(property_path) == value_1:
		is_toggled = false
	else:
		is_toggled = true

func trigger(interactor: Object = null) -> void:
	var target_value: Variant = value_1 if not toggle_mode or is_toggled else value_2
	
	if toggle_mode:
		is_toggled = !is_toggled
	
	#print("Triggered  %s -> %s" % [target_node.get_indexed(property_path), target_value])
	if tween_property:
		create_tween().set_ease(tw_ease).set_trans(tw_trans).tween_property(target_node, property_path, target_value, duration)
	else:
		target_node.set(property_path, target_value)

func _validate_property(property: Dictionary) -> void:
	if not Engine.is_editor_hint(): return
	if not toggle_mode and property.name == &"value_2":
		property.usage &= ~PROPERTY_USAGE_EDITOR
	
	if not tween_property and property.name in ["duration", "tw_ease", "tw_trans"]:
		property.usage &= ~PROPERTY_USAGE_EDITOR
	


# Overwrite component behavior
func _notification(what: int) -> void:
	pass
