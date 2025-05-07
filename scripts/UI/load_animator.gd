@tool
class_name LoadAnimator extends Control

const WIDTH_PERCENTAGE: float = 0.4

@export_range(0.0, 0.99, 0.01,) var margin: float = 0.0:
	set(val): margin = minf(val, 0.99); queue_redraw()

@export var color: Color = Color.WHITE:
	set(val): color = val; queue_redraw()


func _draw() -> void:
	var center: Vector2 = size/2.0
	draw_load(self, center, minf(center.x, center.y) * (1.0 - margin - WIDTH_PERCENTAGE/2.0), color)

func draw_load(item: CanvasItem, pos: Vector2 = Vector2.ZERO, radius: float = 30.0, color = Color.WHITE) -> void:
	const CYCLE_TIME: float = 1.75
	
	const ANG_OFFSET: float = -0.5
	const MIN_ANG: float = -1.0
	
	const TRANS:= Tween.TransitionType.TRANS_CIRC
	
	var width: float = radius*WIDTH_PERCENTAGE
	
	var point_count: int = int(radius*5)
	
	var frames: int = int(CYCLE_TIME * 60)
	var hf: int = frames/2
	var hc: float = CYCLE_TIME/2.0
	
	for i: int in frames:
		var t: float = inverse_lerp(0, frames-1, i)
		
		var t1: float = remap(i, 0, frames, 0.0, CYCLE_TIME)
		var t2: float = remap(i + 1, 0, frames, 0.0, CYCLE_TIME)
		
		var a1: float = \
		Tween.interpolate_value(0.0, TAU, t2, CYCLE_TIME, Tween.TRANS_QUAD, Tween.EASE_IN) + MIN_ANG + ANG_OFFSET
		
		var a2: float = \
		Tween.interpolate_value(0.0, TAU, minf(inverse_lerp(0, frames-1, i+frames/15), hc), hc, TRANS, Tween.EASE_IN_OUT) + ANG_OFFSET \
		- sin((t**2)*PI)
		
		item.draw_animation_slice(CYCLE_TIME, t1, t2, )
		item.draw_arc(pos, radius, a1, a2, point_count, color, width, true)
