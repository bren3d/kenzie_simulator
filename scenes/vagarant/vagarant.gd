@tool
class_name Vagarant extends Node3D

signal match_finished
signal request_exit

@export var ui: CanvasLayer
@export var blackout_rect: ColorRect

var is_active: bool = false

func _ready() -> void:
	if Engine.is_editor_hint(): return
	show()

func enter() -> void:
	is_active = true
	ui.show_menu()

func exit() -> void:
	is_active = false
	request_exit.emit()

func hide_menu() -> void:
	blackout_rect.show()

func show_menu() -> void:
	blackout_rect.hide()

func _on_match_finished() -> void:
	match_finished.emit()
