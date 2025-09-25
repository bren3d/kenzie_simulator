@tool
class_name TriggeredAction extends Component

@export_tool_button("Trigger Action", "Debug")
var action_trigger_callable: Callable = trigger

# TODO -> Add conditionals.
## Target Node is passed as variable [code]target_node[/code].
#@export_custom(PROPERTY_HINT_EXPRESSION, "") 
#var condition_expression: String = ""

@export var action: Action
@export var node_references: Dictionary[String, Node] = {}
@export var references: Dictionary[String, Variant] = {}

func _ready() -> void:
	if Engine.is_editor_hint(): return
	get_parent().get_meta(&"Interactable").interaction_started.connect(trigger)

func trigger(interactor: Object = null) -> void:
	action.execute(node_references.merged(references).merged({host = self, interactor = interactor}))
