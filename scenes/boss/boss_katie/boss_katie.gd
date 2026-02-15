@tool
class_name BossKatie extends Node3D

enum {STATE_INTRO, STATE_EASY, STATE_MEDIUM, STATE_HARD}

const EASY_TRESHOLD: int = 1
const MEDIUM_TRESHOLD: int = 3
const HARD_TRESHOLD: int = 6

signal dead

@export var katie: Katie
@export var hitbox: Area3D
@export var damaged_audio_player: AudioStreamPlayer3D
@export var giggle_audio_player: AudioStreamPlayer3D
@export var particles: GPUParticles3D
@export var movement_component: MovementComponent3D
@export var state_machine: StateMachine

@export var max_hp: int = 10

@export var is_damagable: bool = true

@export var path_pools: Array[Node3D]

var current_hit_count: int = 0:
	set(val):
		current_hit_count = val
		update_boss_state()

var boss_state: int = STATE_INTRO :
	set(val):
		boss_state = val

func update_boss_state() -> void:
	if current_hit_count < EASY_TRESHOLD:
		boss_state = STATE_INTRO
	elif current_hit_count < MEDIUM_TRESHOLD:
		boss_state = STATE_EASY
	elif current_hit_count < HARD_TRESHOLD:
		boss_state = STATE_MEDIUM
	else:
		boss_state = STATE_HARD

func move_to_position(glob_pos: Vector3) -> void:
	movement_component.set_target_position(glob_pos)

func _on_move_speed_changed(new_move_speed: float) -> void:
	if katie: katie.crabwalk_speed = new_move_speed

func _on_hitbox_body_entered(body: Node3D) -> void:
	assert(body is Cat)
	body.explode()
	if is_damagable: state_machine.set_state(&"damaged")

func _on_kill_box_body_entered(body: Node3D) -> void:
	set_state(&"kill")

func set_state(state: StringName) -> void:
	state_machine.set_state(state)

func _process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	state_machine.update_process(delta)

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	state_machine.update_physics_process(delta)

func _input(event: InputEvent) -> void:
	if Engine.is_editor_hint(): return
	state_machine.on_input(event)

func _unhandled_input(event: InputEvent) -> void:
	if Engine.is_editor_hint(): return
	state_machine.on_input(event)
