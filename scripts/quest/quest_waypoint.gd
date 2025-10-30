@tool
class_name QuestWaypoint extends Node3D

@export var quest: Quest:
	set(val):
		quest = val
		notify_property_list_changed()

@export var task_name: String

@export var mesh: Mesh:
	set(val):
		mesh = val
		mesh_instance.mesh = val

@export var animated: bool:
	set(val):
		animated = val
		update_animation()
		notify_property_list_changed()

@export var max_position_delta: Vector3 = Vector3(0.0, 0.3, 0.0):
	set(val):
		max_position_delta = val
		update_animation()
		
@export var half_cycle_duration_sec: float = 0.75:
	set(val):
		half_cycle_duration_sec = val
		update_animation()

@export var tw_trans: Tween.TransitionType = Tween.TransitionType.TRANS_BOUNCE:
	set(val):
		tw_trans = val
		update_animation()

var mesh_instance: MeshInstance3D = MeshInstance3D.new()
var anim_tween: Tween

func _init() -> void:
	add_child(mesh_instance)

func _ready() -> void:
	if Engine.is_editor_hint(): return
	quest.task_updated.connect(_on_task_updated)
	visible = false

func _on_task_updated(t: Task) -> void:
	if t.task_name != task_name: return
	visible = t.is_active()

func update_animation() -> void:
	if anim_tween:
		anim_tween.kill()
		mesh_instance.position = Vector3.ZERO
	
	if not animated: return
	
	anim_tween = create_tween().set_trans(tw_trans).set_ease(Tween.EASE_IN).set_loops()
	anim_tween.tween_property(mesh_instance, ^"position", max_position_delta, half_cycle_duration_sec).as_relative()
	anim_tween.set_ease(Tween.EASE_OUT).tween_property(mesh_instance, ^"position", -max_position_delta, 
	half_cycle_duration_sec).as_relative()

func _validate_property(property: Dictionary) -> void:
	if not Engine.is_editor_hint(): return
	match property.name:
		"max_position_delta", "half_cycle_duration_sec", "tw_trans" when not animated:
			property.usage &= ~PROPERTY_USAGE_EDITOR
		
		"task_name":
			if not quest:
				property.usage &= ~PROPERTY_USAGE_EDITOR
				return
			
			property.hint |= PROPERTY_HINT_ENUM_SUGGESTION
			property.hint_string = quest.get_tasks_hint_string()
