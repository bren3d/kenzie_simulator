@icon("StyleBoxAnimation.svg")
@tool
class_name StyleBoxAnimated extends StyleBox

@export var texture: Texture2D : set = _set_texture
@export var draw_on_right: bool = true

@export var pointer_size: Vector2 = Vector2(64, 32)
@export var pointer_offset: Vector2 = Vector2(8, 0)

@export var canvas_z_index: int = 512

@export_group("Animation")

@export_range(0.0, 10.0, 0.1, "or_greater", "suffix:s")
var duration_sec: float = 1.5

@export_range(0, 100, 1, "or_greater", "suffix:px")
var move_distance: int = 64

var texture_region: Rect2i

var rid: RID

func _set_texture(tex: Texture2D) -> void:
	texture = tex
	texture_region = texture.get_image().get_used_rect() if texture else Rect2i()

func _draw(to_canvas_item: RID, rect: Rect2) -> void:
	if rid:
		RenderingServer.free_rid(rid)
	
	const CANVAS_ITEM_Z_INDEX: int = 512
	rid = RenderingServer.canvas_item_create()
	RenderingServer.canvas_item_set_z_as_relative_to_parent(rid, true)
	RenderingServer.canvas_item_set_z_index(rid, CANVAS_ITEM_Z_INDEX)
	
	RenderingServer.canvas_item_clear(rid)
	RenderingServer.canvas_item_set_parent(rid, to_canvas_item)
	
	canvas_item_draw_pointer(to_canvas_item, draw_on_right)
	
	var canvas_item:= get_current_item_drawn()
	await canvas_item.draw
	canvas_item.draw.connect(RenderingServer.free_rid.bind(rid), CONNECT_ONE_SHOT)


func canvas_item_draw_pointer(parent_rid: RID, draw_on_right: bool = true) -> void:
	if not texture: return
	
	var frame_count: int = move_distance * 2
	var SLICE_TIME_SECS: float = duration_sec / maxf(frame_count, 0.001)
	var draw_size: Vector2 = pointer_size * Vector2(-1, 1) if draw_on_right else pointer_size

	var start_position: Vector2 = (get_current_item_drawn().size * Vector2.RIGHT) + pointer_offset if draw_on_right else -pointer_offset - Vector2(pointer_size.x, 0)

	for i: int in frame_count:
		var t: float = inverse_lerp(0, frame_count, i)
		var pos_offset: Vector2 = Vector2(i if i < move_distance else frame_count - i, 0)
		if not draw_on_right: pos_offset *= Vector2(-1, 0)
		RenderingServer.canvas_item_add_animation_slice(rid, duration_sec, t * duration_sec, t * duration_sec + SLICE_TIME_SECS,)
		RenderingServer.canvas_item_add_texture_rect_region(rid, Rect2(start_position + pos_offset, draw_size), texture.get_rid(), texture_region, Color.WHITE, false, )
