@tool
extends KatieState

func _init() -> void:
	name = &"kill"

func enter() -> void:
	katie.is_damagable = false
	
	#TESTING
	transition_requested.emit(&"charge")
	
	#Global.player.set_state(&"dead")

func exit() -> void:
	pass
