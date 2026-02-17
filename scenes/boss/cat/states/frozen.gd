@tool
extends CatState

func _init() -> void:
	name = &"frozen"

func enter() -> void:
	cat.anim_player.play(&"frozen")
	cat.kickable = false
	cat.freeze = true

func exit() -> void:
	cat.freeze = false
