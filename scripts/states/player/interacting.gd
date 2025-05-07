@tool
extends PlayerState

func _init() -> void:
	name = &"Interacting"

func _ready() -> void:
	if Engine.is_editor_hint(): return
	DialogueManager.dialogue_started.connect(_on_dialogue_started)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)

func enter() -> void:
	player.interact_ray.hovered_interactable.interaction_ended.connect(emit_signal.bind(&"transition_requested", "Moving"), CONNECT_ONE_SHOT)
	player.interact_ray.hovered_interactable.start_interaction(player)

func update_physics_process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	player.velocity.x = move_toward(player.velocity.x, 0.0, player.ACCELERATION * delta)
	player.velocity.z = move_toward(player.velocity.z, 0.0, player.ACCELERATION * delta)
	player.velocity += player.get_gravity() * delta * int(not player.is_on_floor()) 
	player.move_and_slide()

func _on_dialogue_started(res: DialogueResource) -> void:
	if not get_tree().root.window_input.is_connected(_on_root_input):
		get_tree().root.window_input.connect(_on_root_input)

func _on_dialogue_ended(res: DialogueResource) -> void:
	if get_tree().root.window_input.is_connected(_on_root_input):
		get_tree().root.window_input.disconnect(_on_root_input)
	player.clear_camera_zoom()

func _on_root_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		get_tree().set(&"mouse_mode", Input.MOUSE_MODE_VISIBLE)
		get_tree().root.window_input.disconnect(_on_root_input)
