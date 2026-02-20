extends Node

enum {BUS_MASTER = 0, BUS_SFX = 1, BUS_MUSIC = 2,}

var music_stream: AudioStreamPlayer
var sfx_stream: AudioStreamPlayer

var music_fade_tween: Tween

func _init() -> void:
	if Engine.is_editor_hint(): return
	
	const MAX_SFX_COUNT: int = 10
	const MAX_MUSIC_COUNT: int = 1
	
	process_mode = Node.PROCESS_MODE_ALWAYS

	music_stream = AudioStreamPlayer.new()
	add_child(music_stream)
	music_stream.max_polyphony = MAX_MUSIC_COUNT
	music_stream.set_bus.call_deferred(AudioServer.get_bus_name(BUS_MUSIC))
	
	sfx_stream = AudioStreamPlayer.new()
	add_child(sfx_stream)
	sfx_stream.max_polyphony = MAX_SFX_COUNT
	sfx_stream.set_bus.call_deferred(AudioServer.get_bus_name(BUS_SFX))


func set_bus_volume(bus: int, linear_value: float) -> void:
	AudioServer.set_bus_volume_linear(bus, linear_value)


func play_sfx(track: AudioStream) -> void:
	sfx_stream.stream = track
	sfx_stream.play()

func stop_sfx() -> void:
	sfx_stream.stop()

func play_music(track: AudioStream) -> void:
	if music_stream.stream != track:
		music_stream.stream = track
	
	if not music_stream.playing:
		music_stream.play()

func pause_music(fadeout: bool = false) -> void:
	if fadeout:
		if not music_fade_tween or not music_fade_tween.is_valid():
			music_fade_tween = create_tween()
		#if music_fade_tween.is_running():
			#music_fade_tween.stop()
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
	

func _input(event: InputEvent) -> void:
	if event.is_pressed() and not event.is_echo() and event is InputEventKey:
		if event.keycode == KEY_K:
			for i: int in AudioServer.bus_count:
				print("'%s' Bus index = %s" % [AudioServer.get_bus_name(i), i])
				#print("MUSIC BUS = ", AudioServer.get_bus_index(&"Music"))
				#print("SFX BUS = ", AudioServer.get_bus_index(&"Music"))
