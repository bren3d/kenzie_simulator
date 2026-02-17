@tool
class_name TweenParameters extends Resource

@export var trans_type: Tween.TransitionType = Tween.TransitionType.TRANS_LINEAR
@export var ease_type: Tween.EaseType = Tween.EaseType.EASE_IN_OUT

@export_group("Misc")
@export_range(-1, 100, 1, "suffix:loops", "or_greater") 
var loop_count: int = -1

@export var is_parallel: bool

@export_subgroup("Processing and Speed")

@export var pause_mode: Tween.TweenPauseMode = Tween.TweenPauseMode.TWEEN_PAUSE_BOUND
@export var process_mode: Tween.TweenProcessMode = Tween.TweenProcessMode.TWEEN_PROCESS_IDLE

@export_range(0.0, 3.0, 0.01, "or_greater") 
var speed_scale: float = 0.0


func set_parameters(tween: Tween) -> Tween:
	tween.set_trans(trans_type).set_ease(ease_type).set_parallel(is_parallel).set_pause_mode(pause_mode).set_process_mode(process_mode)
	if loop_count > -1:
		tween.set_loops(loop_count)
	if speed_scale > 0.0:
		tween.set_speed_scale(speed_scale)
	return tween

## Not recommended using.
func create_tween() -> Tween:
	return set_parameters(Engine.get_main_loop().create_tween())

func create_tween_bound(node: Node) -> Tween:
	return set_parameters(node.create_tween())
