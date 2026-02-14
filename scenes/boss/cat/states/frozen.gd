@tool
extends CatState

func _init() -> void:
	name = &"frozen"

func enter() -> void:
	cat.anim_player.play(&"frozen")
