@tool
class_name PlayerState extends State

var player: Player

func _init() -> void:
	name = &"PlayerState"

func set_host(host: Node) -> void:
	player = host

func update_physics_process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	player.velocity += player.get_gravity() * delta * int(not player.is_on_floor()) 
	player.move_and_slide()
