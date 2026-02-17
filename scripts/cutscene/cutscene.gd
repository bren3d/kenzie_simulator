@tool
@abstract class_name Cutscene 
extends Node

signal started
signal finished

@export var skippable: bool

var is_active: bool = false

#func _ready() -> void:
	#set_process_input(false)
	#if not Engine.is_editor_hint() and play_on_ready:
		#play()

## Will change player state to "Cutscene"
func play() -> void:
	is_active = true
	if skippable:
		set_process_input(true)
	Global.player.set_state.call_deferred("Cutscene")
	started.emit()
	_on_play()

## Will reset player state and camera
func finish() -> void:
	Global.player.set_state("Moving")
	Global.player.make_camera_current()
	is_active = false
	finished.emit()

## To be overwritten
func skip() -> void:
	finish()

@abstract func _on_play() -> void

func _input(event: InputEvent) -> void:
	if is_active and skippable and event.is_action_pressed(&"skip"):
		skip()
		get_viewport().set_input_as_handled()

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_READY:
			set_process_input(false)
