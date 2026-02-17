@tool
class_name CatSpawner extends Node

@export_tool_button("Spawn") 
var spawn_callable: Callable = spawn

@export var cat_scene: PackedScene

@export var spawn_locations: Array[Node3D]
@export var patrol_points: Array[Node3D]

@export var active: bool = true
@export var disable_collision_duration_sec: float = 1.0
@export var cat_spawn_delay_sec: float = 1.5

@export var max_cat_count: int = 5

var current_cat_count: int = 0

var current_delay_sec: float = 0.0

func spawn() -> void:
	var cat: Cat = cat_scene.instantiate()
	
	if not Engine.is_editor_hint():
		current_cat_count += 1
		cat.tree_exiting.connect(_on_cat_tree_exiting, CONNECT_ONE_SHOT)
	
	cat.patrol_points = patrol_points
	
	cat.global_transform = get_spawn_transform()
	cat.set_collision_mask_value(1, false)
	create_tween().tween_callback(cat.set_collision_mask_value.bind(1, true)).set_delay(disable_collision_duration_sec)
	
	add_sibling(cat)
	
	if Engine.is_editor_hint():
		cat.owner = owner
		return
	
	cat.set_state(&"patrol")

func get_spawn_transform() -> Transform3D:
	return spawn_locations.pick_random().global_transform

func _process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	current_delay_sec += delta
	if not active: return
	if current_delay_sec >= cat_spawn_delay_sec and current_cat_count < max_cat_count:
		current_delay_sec = 0.0
		spawn()


func _on_cat_tree_exiting() -> void:
	current_cat_count -= 1

# TESTING
func _input(event: InputEvent) -> void:
	if event.is_pressed() and not event.is_echo() and event is InputEventKey:
		if event.keycode == KEY_Q:
			spawn()
