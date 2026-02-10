@tool
class_name Crosshair extends Control

@export var radius: float = 1.5
@export_color_no_alpha var color: Color = Color.WHITE

func _draw() -> void:
	draw_circle(Vector2.ZERO, radius, color, true, -1.0, false)
