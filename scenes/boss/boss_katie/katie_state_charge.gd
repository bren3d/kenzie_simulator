@tool
extends KatieState

const DEFAULT_CHARGE_SPEED: float = 1.0

#@export var charge_speeds: PackedFloat32Array

var boss_state: int = -1
var path_pool: Array[PathFollow3D]

var charge_path_follow: PathFollow3D

func _init() -> void:
	name = &"charge"

func enter() -> void:
	if katie.path_pools.is_empty():
		push_warning("No path_pools set, aborting charge state...")
		transition_requested.emit(&"idle")
		return
	
	katie.movement_component.stop()
	katie.katie.play(&"crabwalk")
	katie.is_damagable = true
	
	if boss_state != katie.boss_state or path_pool.is_empty():
		update_path_pool()
	
	charge_path_follow = get_charge_path()
	katie.movement_component.move_speed = get_charge_speed()
	
	charge_path_follow.progress = 0.0
	sync_path_follow()
	
	katie.giggle_audio_player.play()
	
	katie.set_killbox_active(true)

func exit() -> void:
	charge_path_follow = null
	katie.giggle_audio_player.stop()

func update_physics_process(delta: float) -> void:
	if charge_path_follow:
		charge_path_follow.progress += katie.movement_component.move_speed * delta
		sync_path_follow()
		if charge_path_follow.progress_ratio >= 1.0:
			transition_requested.emit(&"attack")

func sync_path_follow() -> void:
	katie.global_position = charge_path_follow.global_position
	katie.global_rotation = charge_path_follow.global_rotation

func update_path_pool() -> void:
	path_pool = get_path_pool()
	boss_state = katie.boss_state

func get_charge_path() -> PathFollow3D:
	var idx: int = randi() % path_pool.size()
	var path_follow: PathFollow3D = path_pool[idx]
	if not Engine.is_editor_hint():
		path_pool.remove_at(idx)
	return path_follow

func get_path_pool() -> Array[PathFollow3D]:
	var p: Array[PathFollow3D]
	for child in katie.path_pools[katie.boss_state].get_children():
		if not child is Path3D or not child.get_child_count(): continue
		p.push_back(child.get_child(0))
	return p

func get_charge_speed() -> float:
	if not charge_path_follow:
		return DEFAULT_CHARGE_SPEED
	return charge_path_follow.get_parent().get_meta(&"speed", DEFAULT_CHARGE_SPEED)
