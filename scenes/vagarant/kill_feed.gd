@tool
class_name KillFeed extends GridContainer

@export_range(0.5, 10.0, 0.1, "suffix:s") 
var show_duration_sec: float = 4.0

@export var kill_icon: Texture
@export var headshot_icon: Texture

@export var label_a: Label
@export var icon_texture_rect: TextureRect
@export var label_b: Label


func _ready() -> void:
	if Engine.is_editor_hint(): return
	label_a.hide()
	icon_texture_rect.hide()
	label_b.hide()

func update(dead_combatant: Combatant, killer: Node3D) -> void:
	var killer_label: Label = label_a.duplicate()
	var text_rect: TextureRect = icon_texture_rect.duplicate()
	var dead_label: Label = label_b.duplicate()
	
	killer_label.text = killer.get_display_name()
	dead_label.text = dead_combatant.get_display_name()
	text_rect.texture = headshot_icon if killer is VagarantPlayer else kill_icon
	
	add_child(killer_label)
	add_child(text_rect)
	add_child(dead_label)
	
	killer_label.show()
	text_rect.show()
	dead_label.show()
	
	var tw: Tween = create_tween()
	tw.tween_interval(show_duration_sec)
	tw.tween_callback(killer_label.hide)
	tw.tween_callback(text_rect.hide)
	tw.tween_callback(dead_label.hide)
	
