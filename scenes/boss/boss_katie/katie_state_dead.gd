@tool
extends KatieState

func _init() -> void:
	name = &"dead"

func enter() -> void:
	katie.hide()
	lock_state.emit(true)
	katie.dead.emit()
