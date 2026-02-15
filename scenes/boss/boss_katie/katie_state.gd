@tool
class_name KatieState extends State

var katie: BossKatie

func _init() -> void:
	name = &"KatieState"

func set_host(host: Node) -> void:
	katie = host
