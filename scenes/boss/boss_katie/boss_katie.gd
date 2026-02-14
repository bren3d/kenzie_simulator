@tool
class_name BossKatie extends Node3D

@export var katie: Katie
@export var hitbox: Area3D
@export var audio_player: AudioStreamPlayer3D
@export var particles: GPUParticles3D
@export var movement_component: MovementComponent3D

func move_to_position(glob_pos: Vector3) -> void:
	pass

func _on_move_speed_changed(new_move_speed: float) -> void:
	if katie: katie.crabwalk_speed = new_move_speed
