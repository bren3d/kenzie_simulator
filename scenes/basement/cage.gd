class_name AnimalCage extends Node3D

@export var dialogue_action: DialogueAction
@export var task_updater: TaskUpdater
@export var quest: Quest
@export var task_name: String

@export var feed_mode_active: bool: set = set_feed_mode_active
@export var feed_text: String = "Feed"
@export var default_icon: Texture2D
@export var feed_icon: Texture2D

@export var open_can_audio: AudioStream
@export var pour_food_audio: AudioStream

@export var blackout_filter: ColorRect

@export var food_mesh: MeshInstance3D

@export var animals: Array[Node3D]
@export var eating_positions: Array[Node3D]

@export var fade_duration_sec: float = 0.5
@export var food_open_pause_duration_sec: float = 0.35

func _ready() -> void:
	if Engine.is_editor_hint(): return
	food_mesh.visible = false
	var interactable: Interactable = get_meta(&"Interactable")
	interactable.interaction_started.disconnect(dialogue_action.start)
	interactable.interaction_started.connect(_on_interaction_started)

func set_feed_mode_active(val: bool) -> void:
	feed_mode_active = val
	var interactable: Interactable = get_meta(&"Interactable")
	if not interactable: return
	interactable.interaction_text = feed_text if feed_mode_active else ""
	interactable.icon = feed_icon if feed_mode_active else default_icon

func _on_interaction_started(interactor: Object) -> void:
	if feed_mode_active:
		feed()
		return
	
	else:
		dialogue_action.start(interactor)

func feed() -> void:
	Global.player.set_state.call_deferred("Cutscene")
	
	feed_mode_active = false
	
	task_updater.quest = quest
	task_updater.task_name = task_name
	
	var tw: Tween = create_tween()
	tw.tween_property(blackout_filter, ^"color:a", 1.0, fade_duration_sec)
	tw.tween_callback(Audio.play_sfx.bind(open_can_audio))
	tw.tween_interval(open_can_audio.get_length() + food_open_pause_duration_sec)
	tw.tween_callback(Audio.play_sfx.bind(pour_food_audio))
	tw.tween_interval(pour_food_audio.get_length())
	tw.tween_callback(food_mesh.show)
	tw.tween_callback(move_animals)
	
	tw.tween_property(blackout_filter, ^"color:a", 0.0, fade_duration_sec)
	
	tw.tween_callback(Global.player.set_state.bind("Moving"))
	
	tw.tween_callback(task_updater.update_task)

func move_animals() -> void:
	assert(animals.size() == eating_positions.size())
	for i: int in animals.size():
		animals[i].global_position = eating_positions[i].global_position
		animals[i].global_rotation = eating_positions[i].global_rotation
