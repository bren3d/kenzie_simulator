@tool
extends CatState

var path_index: int = 0

func _init() -> void:
	name = &"patrol"

func enter() -> void:
	assert(cat.patrol_points.size() > 1)
	cat.kickable = true
	move_to_patrol_index(0)

func exit() -> void:
	if cat.movement.movement_finished.is_connected(_on_movement_finished):
		cat.movement.movement_finished.disconnect(_on_movement_finished)
	cat.movement.active = false

func move_to_patrol_index(idx: int) -> void:
	assert(idx < cat.patrol_points.size())
	path_index = idx
	cat.movement.target_global_position = cat.patrol_points[path_index].global_position
	cat.movement.movement_finished.connect(_on_movement_finished, CONNECT_ONE_SHOT | CONNECT_DEFERRED)

func _on_movement_finished() -> void:
	move_to_patrol_index((path_index + 1) % cat.patrol_points.size())

func on_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"kick") and cat.is_kickable():
		transition_requested.emit(&"kicked")
		get_viewport().set_input_as_handled()
