@tool
extends KatieState

func _init() -> void:
	name = &"attack"

func enter() -> void:
	#Global.player.death_message = "Katie killed you"
	katie.is_damagable = false
	katie.set_killbox_active(false)
	katie.hit_player.emit()
