@tool
extends Cutscene

@export var audio_player: AudioStreamPlayer
@export var camera_shaker: CameraShaker
@export var dialogue: DialogueResource

func _on_play() -> void:
	if Engine.is_editor_hint(): return
	
	Audio.pause_music(true)
	
	DialogueManager.show_dialogue_balloon(dialogue,"", [{player = audio_player, shaker = camera_shaker}])
	DialogueManager.dialogue_ended.connect(finish.unbind(1))
