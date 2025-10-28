extends Node

enum {BUS_MASTER = 0, BUS_MUSIC = 1, BUS_SFX = 2,}

const BUS_SFX_NAME: StringName = &"SFX"
const BUS_MUSIC_NAME: StringName = &"Music"

var music_stream: AudioStreamPlayer
var sfx_stream: AudioStreamPlayer

var music_fade_tween: Tween

func _init() -> void:
	if Engine.is_editor_hint(): return
	
	const MAX_SFX_COUNT: int = 10
	const MAX_MUSIC_COUNT: int = 1
	
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	AudioServer.add_bus(BUS_MUSIC)
	AudioServer.set_bus_name(BUS_MUSIC, BUS_MUSIC_NAME)
	
	AudioServer.add_bus(BUS_SFX)
	AudioServer.set_bus_name(BUS_SFX, BUS_SFX_NAME)
	
	music_stream = AudioStreamPlayer.new()
	music_stream.bus = BUS_MUSIC_NAME
	music_stream.max_polyphony = MAX_MUSIC_COUNT
	add_child(music_stream)
	
	sfx_stream = AudioStreamPlayer.new()
	sfx_stream.volume_db
	sfx_stream.bus = BUS_SFX_NAME
	sfx_stream.max_polyphony = MAX_SFX_COUNT
	add_child(sfx_stream)


func change_bus_volume(bus: int, linear_value: float) -> void:
	
	match bus:
		
		BUS_MUSIC:
			music_stream.volume_linear = linear_value
		
		BUS_SFX:
			sfx_stream.volume_linear = linear_value

func play_sfx(track: AudioStream) -> void:
	sfx_stream.stream = track
	sfx_stream.play()

func play_music(track: AudioStream) -> void:
	if music_stream.stream == track: return
	
	if music_stream.stream != track:
		music_stream.stream = track
	
	if not music_stream.playing:
		music_stream.play()

func pause_music(fadeout: bool = false) -> void:
	if fadeout:
		if not music_fade_tween or not music_fade_tween.is_valid():
			music_fade_tween = create_tween()
		music_fade_tween.tween_property(music_stream, ^"volume_linear", 0.0, 1.0)
		music_fade_tween.tween_callback(music_stream.set_stream_paused.bind(true))
		music_fade_tween.tween_callback(music_stream.set_volume_linear.bind(1.0))
	
	else:
		music_stream.stream_paused = true

func unpause_music() -> void:
	if music_fade_tween:
		music_fade_tween.kill()
	music_stream.volume_linear = 1.0
	music_stream.stream_paused = false
	
