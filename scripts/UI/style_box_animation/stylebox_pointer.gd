@tool
class_name StyleBoxAnimated extends StyleBox

const TEXTURE_REGION: Rect2i = Rect2i(52, 146, 421, 237)
const TEXTURE: Texture2D = preload("hand_icon.png")

@export var texture: Texture2D : set = _set_texture
@export var draw_on_right: bool = true

@export var pointer_size: Vector2 = Vector2(-128, 64)
@export var pointer_offset: Vector2 = Vector2(10, 0)

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
	
	var SIZE: Vector2 = pointer_size
	var POINTER_OFFSET_PIXELS: Vector2 = pointer_offset
	var TIME_SECS: float = duration_sec
	var MOVE_PIXELS: int = move_distance
	var TOTAL_FRAMES: int = MOVE_PIXELS * 2
	var SLICE_TIME_SECS: float = TIME_SECS / TOTAL_FRAMES
	var draw_size: Vector2 = SIZE if draw_on_right else SIZE * Vector2(-1, 1)

	var start_position: Vector2 = (get_current_item_drawn().size * Vector2.RIGHT) + POINTER_OFFSET_PIXELS if draw_on_right else -POINTER_OFFSET_PIXELS + Vector2(SIZE.x, 0)

	for i: int in TOTAL_FRAMES:
		var t: float = inverse_lerp(0, TOTAL_FRAMES, i)
		var pos_offset: Vector2 = Vector2(i if i < MOVE_PIXELS else TOTAL_FRAMES - i, 0)
		if not draw_on_right: pos_offset *= Vector2(-1, 0)
		RenderingServer.canvas_item_add_animation_slice(rid, TIME_SECS, t * TIME_SECS, t * TIME_SECS + SLICE_TIME_SECS,)
		RenderingServer.canvas_item_add_texture_rect_region(rid, Rect2(start_position + pos_offset, draw_size), TEXTURE.get_rid(), TEXTURE_REGION, Color.WHITE, false, )
