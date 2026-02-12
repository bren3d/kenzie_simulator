@tool
class_name Gun extends Node3D

const MUZZLE_FLASH_DURATION: float = 0.04
const SHOOT_DELAY: float = 0.075

signal shot


@export_tool_button("Shoot") 
var shoot_callable: Callable = shoot

@export var pivot: Node3D
@export var gun_sprite: Sprite3D
@export var flash_sprite: Sprite3D
@export var audio_stream: AudioStreamPlayer

@export_range(0.0, 90.0, 1.0, "radians_as_degrees") var recoil_amount: float = PI/16.0
@export_range(0.0, 1.0, 0.05, ) var recoil_duration_sec: float = 0.05

@export_range(0.0, 180.0, 1.0, "radians_as_degrees") var recoil_return_speed: float = PI/4.0

@export var shoot_delay_sec: float = 0.075

var shoot_cooldown_timer: float = 0.0

func shoot() -> void:
	if shoot_cooldown_timer > 0.0: return
	
	create_tween().tween_property(pivot, ^"rotation:z", -recoil_amount, recoil_duration_sec ).as_relative()
	play_muzzle_flash()
	audio_stream.play()
	
	shoot_cooldown_timer = shoot_delay_sec
	
	shot.emit()
	

func play_muzzle_flash() -> void:
	flash_sprite.show()
	create_tween().tween_callback(flash_sprite.hide).set_delay(MUZZLE_FLASH_DURATION)

func _process(delta: float) -> void:
	shoot_cooldown_timer -= delta
	#if not Engine.is_editor_hint() and Input.is_action_pressed(&"shoot"):
		#shoot()
	if pivot:
		pivot.rotation.z = move_toward(pivot.rotation.z, 0.0, recoil_return_speed * delta)
