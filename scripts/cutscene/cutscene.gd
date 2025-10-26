@tool
@abstract class_name Cutscene 
extends Node

signal started
signal finished

@export var play_on_ready: bool

func _ready() -> void:
	if Engine.is_editor_hint(): return
	if play_on_ready:
		play()


func play() -> void:
	var player := get_tree().get_first_node_in_group(&"Player")
	if player and player.has_method("set_state"):
		player.set_state("Cutscene")
	started.emit()
	_on_play()


@abstract func _on_play() -> void
