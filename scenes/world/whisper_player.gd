@tool
extends AudioStreamPlayer

@export var player: Player

@export_range(0.0, 1.0, 0.01)
var min_volume: float = 0.1

@export_range(0.0, 1.0, 0.01, "or_greater")
var max_volume: float = 1.0

@export_range(0.0, 1000.0, 5.0, "or_greater", "exp", "suffix:m") 
var min_distance: float = 0.0

@export_range(0.0, 1000.0, 5.0, "or_greater", "exp", "suffix:m") 
var max_distance: float = 200.0

@export var music_ambient: AudioStream
@export var music_suspense: AudioStream

@export_range(0.0, 0.99, 0.01)
var music_change_threshold: float = 0.7

@export_range(0.0, 1.0, 0.01, "or_greater")
var music_volume_min: float = 0.3

@export_range(0.0, 1.0, 0.01, "or_greater")
var music_volume_max: float = 0.7

var is_suspense_playing: bool

func _ready() -> void:
	if Engine.is_editor_hint() or not stream: return
	
	Audio.change_bus_volume(Audio.BUS_MUSIC, music_volume_min)
	Audio.play_music(music_ambient)
	
	volume_linear = min_volume
	var tw: Tween = create_tween().set_loops(max_polyphony)
	tw.tween_callback(play)
	tw.tween_interval(stream.get_length()/max_polyphony)


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	var t: float = clampf(inverse_lerp(min_distance, max_distance, player.position.length()), 0.0, 1.0)
	volume_linear = lerpf(min_volume, max_volume, t)
	
	Audio.change_bus_volume(Audio.BUS_MUSIC, lerpf(music_volume_min, music_volume_max, t))
	
	if not is_suspense_playing and t > music_change_threshold:
		Audio.play_music(music_suspense)
		is_suspense_playing = true
	
	#volume_linear = minf(max_volume, remap(maxf(player.position.length(), min_distance), min_distance, max_distance, min_volume, max_volume))
