@tool
class_name StateMachine extends Node

signal state_changed(old_state: State, new_state: State)

## Name of state to initially switch to. No effect if set after parent [member ready] called.
@export_placeholder("Idle") 
var initial_state: String

#@export_category("Debug")

## This is saved as node so Label and Label3D can be used. 
## Will set labels text regardless of the value [member debug_mode] is set to.
@export var debug_label: Node

## Toggles printing state changes to console.
@export var debug_mode: bool

## State Lookup by name.
var states: Dictionary[String, State]

## Prevents transitioning to other states when true.
var state_locked: bool: set = set_state_locked

## The active state currently being updated.
var current_state: State: set = set_current_state

## Dictionary of variables shared by states.
var blackboard: Dictionary = {
	previous_state = null,
}

func _ready() -> void:
	var parent: Node = get_parent()
	
	if not parent.is_node_ready():
		await parent.ready
	
	for state: State in get_state_nodes():
		add_state(state)
	
	if not Engine.is_editor_hint():
		current_state = get_state(initial_state) if initial_state else get_state_nodes().front()

func add_state(state: State) -> void:
	states[state.name] = state
	state.blackboard = blackboard
	state.set_host(get_parent())
	states[state.name].transition_requested.connect(_on_transition_requested)
	states[state.name].lock_state.connect(_on_lock_state)

func set_current_state(new_state: State) -> void:
	if not new_state or new_state == current_state: return
	
	blackboard.previous_state = current_state
	
	if debug_mode:
		print("CALLED TRANSITION : %s -> %s" % [current_state.name if current_state else "<NULL>", new_state.name])
	
	if current_state: 
		current_state.exit()
	
	current_state = new_state
	
	if debug_label:
		debug_label.set(&"text", current_state.name if current_state else "")
	
	current_state.enter()
	
	state_changed.emit(blackboard.previous_state, current_state)

## General function to switch state manually (such as debug).
func set_state(state_name: String) -> void:
	if state_locked: return
	current_state = get_state(state_name)

## Finds given state node from given name.
func get_state(state_name: String) -> State:
	return states.get(state_name)

## Returns all States that are children.
func get_state_nodes() -> Array[State]:
	var result: Array[State]
	for child in get_children():
		if child is State: result.push_back(child)
	return result


func set_state_locked(set_locked: bool) -> void:
	if set_locked == state_locked: return
	state_locked = set_locked

## Sets state regardless of [state_locked].
func _on_force_state(state_name: String) -> void:
	assert(states.has(state_name), "State '%s' not found " % str(state_name))
	current_state = get_state(state_name)

## If not [state_locked], will set current state = get_state(state_name)
func _on_transition_requested(state_name: String) -> void:
	set_state(state_name)

func _on_lock_state(set_locked: bool) -> void:
	state_locked = set_locked

#region Updates

func update_physics_process(delta: float) -> void:
	if current_state: current_state.update_physics_process(delta)

func update_process(delta: float) -> void:
	if current_state: current_state.update_process(delta)

func on_input(event: InputEvent) -> void:
	if current_state: current_state.on_input(event)

func on_unhandled_input(event: InputEvent) -> void:
	if current_state: current_state.on_unhandled_input(event)

func on_mouse_entered() -> void:
	if current_state: current_state.on_mouse_entered()

func on_mouse_exited() -> void:
	if current_state: current_state.on_mouse_exited()

func update_integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if current_state: current_state.update_integrate_forces(state)

#endregion

func _validate_property(property: Dictionary) -> void:
	match property.name:
		&"initial_state" when Engine.is_editor_hint():
			property.hint = PROPERTY_HINT_ENUM
			property.hint_string = ",".join(get_state_nodes().map(func(s: State) -> String: return s.name))
