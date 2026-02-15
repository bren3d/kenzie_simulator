@tool
extends Cutscene

@export var door: Door
@export var boss_scene: PackedScene

func _on_play() -> void:
	if Engine.is_editor_hint(): return
	Global.player.set_flashlight_active(false)
	#door.set_open(false)
	#door.set_locked(true)
	
	get_tree().change_scene_packed(boss_scene)
