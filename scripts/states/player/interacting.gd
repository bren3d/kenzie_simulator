@tool
extends PlayerState

func _init() -> void:
	name = &"Interacting"

func enter() -> void:
	player.interact_ray.hovered_interactable.interaction_ended.connect(emit_signal.bind(&"transition_requested", "Moving"), CONNECT_ONE_SHOT)
	player.interact_ray.hovered_interactable.start_interaction(player)

func update_physics_process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	player.velocity += player.get_gravity() * delta * int(not player.is_on_floor()) 
	player.move_and_slide()
