@tool
class_name Cat extends RigidBody3D

const ANIM_WALK: StringName = &"walk"
const ANIM_FROZEN: StringName = &"frozen"

@export var anim_player: AnimationPlayer
@export var state_machine: StateMachine
@export var movement: RigidBodyMovement
@export var kickable_area: Area3D
@export var audio_player: AudioStreamPlayer3D
@export var blood_explosion_audio_player: AudioStreamPlayer3D
@export var cat_mesh: Node3D
@export var particles: GPUParticles3D

@export var patrol_points: Array[Node3D]

@export var kickable: bool = true:
	set(val):
		kickable = val
		kickable_area.set_monitorable.call_deferred(val)
		kickable_area.set_monitoring.call_deferred(val)

@export var cat_name: String = ""

func explode() -> void:
	set_state(&"explode")

func kick() -> void:
	set_state(&"kicked")

func is_kickable() -> bool:
	return kickable and kickable_area.has_overlapping_areas()

func _on_movement_handle_movement_started() -> void:
	if not anim_player.current_animation == ANIM_WALK:
		anim_player.play(ANIM_WALK)

func _on_movement_handle_movement_finished() -> void:
	anim_player.play(ANIM_FROZEN)

func play_sound(sfx: AudioStream) -> void:
	audio_player.stream = sfx
	audio_player.play()

func set_state(state: StringName) -> void:
	state_machine.set_state(state)

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if Engine.is_editor_hint(): return
	state_machine.update_integrate_forces(state)

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
	state_machine.on_unhandled_input(event)
