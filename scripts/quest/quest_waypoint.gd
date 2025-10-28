@tool
class_name QuestWaypoint extends MeshInstance3D

@export var quest: Quest
@export var task_name: String
@export var animated: bool:
	set(val):
		animated = val
		set_physics_process(animated)

@export var max_position_delta: Vector3 = Vector3(0.0, -0.3, 0.0)
@export var half_cycle_duration_sec: float = 0.5
@export var tw_ease: Tween.EaseType = Tween.EaseType.EASE_IN_OUT
@export var tw_trans: Tween.TransitionType = Tween.TransitionType.TRANS_SINE

@export_tool_button("Test Animation") var animation_cycle_callable: Callable = \
func() -> void: 
	var tw: Tween = create_tween().set_trans(tw_trans).set_ease(tw_ease)
	tw.tween_property(self, ^"position", max_position_delta, half_cycle_duration_sec).as_relative()
	tw.tween_property(self, ^"position", -max_position_delta, half_cycle_duration_sec).as_relative()


func _ready() -> void:
	if Engine.is_editor_hint(): return
	quest.task_updated.connect(_on_task_updated)
	visible = false
	if animated:
		var tw: Tween = create_tween().set_trans(tw_trans).set_ease(tw_ease).set_loops()
		tw.tween_property(self, ^"position", max_position_delta, half_cycle_duration_sec).as_relative()
		tw.tween_property(self, ^"position", -max_position_delta, half_cycle_duration_sec).as_relative()

func _on_task_updated(t: Task) -> void:
	if t.task_name != task_name: return
	#print("Task active: %s" %  t.is_active())
	visible = t.is_active()
