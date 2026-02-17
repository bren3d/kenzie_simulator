@tool
extends Area3D

@export var interact_ray: InteractRay

@export var interact_label: Label
@export var message_icon: TextureRect
@export var interact_icon: TextureRect

@export var kick_icon: Texture
@export var input_icon: Texture

func _ready() -> void:
	if Engine.is_editor_hint(): return
	area_entered.connect(update_ui.unbind(1))
	area_exited.connect(update_ui.unbind(1))

func update_ui() -> void:
	for area in get_overlapping_areas():
		var cat: Cat = area.get_parent()
		if cat and cat.kickable:
			set_ui(cat)
			return
	
	clear_ui()

func set_ui(cat: Cat) -> void:
	interact_ray.set_interaction_text("Kick %s" % cat.cat_name if cat.cat_name else "Kick" )
	interact_ray.set_interaction_icon(kick_icon)
	interact_ray.set_message_icon(input_icon)

func clear_ui() -> void:
	interact_ray.set_interaction_text("")
	interact_ray.set_interaction_icon(null)
	interact_ray.set_message_icon(null)
