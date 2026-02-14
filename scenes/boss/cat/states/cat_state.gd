@tool
class_name CatState extends State

var cat: Cat

func _init() -> void:
	name = &"CatState"

func set_host(host: Node) -> void:
	cat = host

func update_integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	pass
