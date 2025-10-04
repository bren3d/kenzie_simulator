@tool
class_name TriggerMethod extends Component

@export_tool_button("Trigger Action", "Debug")
var action_trigger_callable: Callable = trigger

@export var target_node: Node

@export var method_name: String

#@export var toggle_mode: bool:
	#set(val):
		#toggle_mode = val
		#notify_property_list_changed()

#@export var tween_property: bool:
	#set(val):
		#tween_property = val
		#notify_property_list_changed()
#
#@export_group("Tween Properties")
#@export var duration: float = 1.0
#@export var tw_ease: Tween.EaseType = Tween.EaseType.EASE_IN_OUT
#@export var tw_trans: Tween.TransitionType = Tween.TransitionType.TRANS_LINEAR

#var is_toggled: bool


func _ready() -> void:
	if Engine.is_editor_hint(): return
	get_parent().get_meta(&"Interactable").interaction_started.connect(trigger)
	
	#if not toggle_mode: return
	#
	#if (value_1 is float and is_equal_approx(target_node.get_indexed(property_path), value_1)):
		#is_toggled = false
	#elif target_node.get_indexed(property_path) == value_1:
		#is_toggled = false
	#else:
		#is_toggled = true

func trigger(interactor: Object = null) -> void:
	target_node.call(method_name)

# Overwrite component behavior
func _notification(what: int) -> void:
	pass
