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

func _ready() -> void:
	if Engine.is_editor_hint() or not stream: return
	volume_linear = min_volume
	var tw: Tween = create_tween().set_loops(max_polyphony)
	tw.tween_callback(play)
	tw.tween_interval(stream.get_length()/max_polyphony)


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	volume_linear = minf(max_volume, remap(maxf(player.position.length(), min_distance), min_distance, max_distance, min_volume, max_volume))
