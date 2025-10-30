@tool
@abstract class_name Cutscene 
extends Node

signal started
signal finished

@export var play_on_ready: bool

func _ready() -> void:
	if not Engine.is_editor_hint() and play_on_ready:
		play()

func play() -> void:
	var player := Global.player
	if player and player.has_method("set_state"):
		player.set_state.call_deferred("Cutscene")
	started.emit()
	_on_play()


@abstract func _on_play() -> void
