@tool
extends PlayerState

@export var ray: RayCast3D
@export var interact_label: Label

func _init() -> void:
	name = &"Interacting"

func set_host(host: Node) -> void:
	player = host
	player.interact_ray.collision_mask = Interactable.COLLISION_LAYER

func enter() -> void:
	player.interactable = player.interact_ray.get_collider().get_meta(&"Interactable")
	player.interactable.open()
	player.input_active = false
	player.interact_ray.enabled = false

func exit() -> void:
	player.interactable.close()
	player.interactable = null
	player.input_active = true
	player.interact_ray.enabled = true

func _physics_process(delta: float) -> void:
	if not ray or not ray.is_colliding(): return
	
	if not ray.get_collider().has_meta(&"Interactable"):
		return
	
	var interactable: Interactable = ray.get_collider().get_meta(&"Interactable")
	
	if not player.interact_ray.enabled or not player.interact_ray.is_colliding():
		player.interact_label.text = ""
		return
	

func update_physics_process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	player.velocity += player.get_gravity() * delta * int(not player.is_on_floor()) 
	player.move_and_slide()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"interact") and player.interact_ray.enabled and player.interact_ray.is_colliding():
		get_viewport().set_input_as_handled()

func on_input(event: InputEvent) -> void:
	pass

func on_unhandled_input(event: InputEvent) -> void:
	pass

func on_mouse_entered() -> void:
	pass

func on_mouse_exited() -> void:
	pass
