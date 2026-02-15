@tool
extends KatieState

@export var scream_audio_streams: Array[AudioStream]
@export var charge_delay: float = 1.0

var current_delay_sec: float = 0.0

func _init() -> void:
	name = &"damaged"

func enter() -> void:
	katie.current_hit_count += 1
	katie.is_damagable = false
	katie.katie.hide()
	katie.movement_component.stop()
	katie.particles.emitting = true
	katie.damaged_audio_player.play()
	current_delay_sec = 0.0

func exit() -> void:
	katie.is_damagable = true
	katie.katie.show()

func update_process(delta: float) -> void:
	current_delay_sec += delta
	if current_delay_sec > charge_delay:
		transition_requested.emit(&"charge")
