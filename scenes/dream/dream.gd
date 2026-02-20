@tool
extends Node3D

@export var basement_scene: PackedScene
@export var player_scene: PackedScene

func _ready() -> void:
	set_process_input(false)

func play() -> void:
	var player: Player = player_scene.instantiate()
	add_child(player)
	Global.play_wake_up_cutscene_on_ready = true
	player.show_message("WASD to move\nShift to Sprint", -1.0)
	set_process_input(true)

func _on_area_exit_body_exited(body: Node3D) -> void:
	if Engine.is_editor_hint() or not body is Player: return
	if body.position.length() < 150.0: return
	print("BODY EXITED AREA")
	get_tree().change_scene_packed(basement_scene)
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"left") or \
		event.is_action_pressed(&"right") or \
		event.is_action_pressed(&"up") or \
		event.is_action_pressed(&"down"):
			Global.player.hide_message()
			set_process_input(false)
			print("Cancelled!")
