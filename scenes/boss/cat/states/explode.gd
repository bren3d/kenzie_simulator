@tool
extends CatState

func _init() -> void:
	name = &"explode"

func enter() -> void:
	cat.cat_mesh.hide()
	cat.blood_explosion_audio_player.play()
	cat.set_freeze_enabled.call_deferred( true)
	cat.particles.emitting = true
	cat.particles.finished.connect(_on_particles_finished, CONNECT_DEFERRED)

func _on_particles_finished() -> void:
	cat.queue_free()
