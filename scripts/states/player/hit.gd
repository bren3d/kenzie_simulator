@tool
extends PlayerState

@export var hit_sound_player: AudioStreamPlayer
@export var hit_texture_rect: TextureRect

@export var tween_in_params: TweenParameters
@export var tween_out_params: TweenParameters

@export_range(0.0, 2.0, 0.05) 
var hit_fade_in_sec: float = 0.25

@export_range(0.0, 10.0, 0.05) 
var hit_fade_out_sec: float = 3.0

func _init() -> void:
	name = &"Hit"

func enter() -> void:
	player.current_hit_count += 1
	hit_sound_player.play()
	
	show_hit_display()
	
	if player.is_dead():
		player.kill()
		return
	
	transition_requested.emit(blackboard.previous_state.name)


func show_hit_display() -> void:
	var tween_out: Tween = tween_out_params.create_tween_bound(self)
	tween_out.tween_property(hit_texture_rect, ^"modulate:a", 0.0, hit_fade_out_sec)
	
	var tween_in: Tween = tween_in_params.create_tween_bound(self)
	tween_in.tween_property(hit_texture_rect, ^"modulate:a", 1.0, hit_fade_in_sec)
	tween_in.tween_subtween(tween_out)


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		if event.keycode == KEY_O:
			transition_requested.emit(name)
