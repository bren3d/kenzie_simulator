class_name Master extends SceneTree

const SETTING_TRANSITION: String = "application/config/scene_transition_duration_sec"
const TRANSITION_RECT_NAME: String = "MasterTransitionRect"

const DEBUG_SCENE_PATHS:PackedStringArray = [
	"res://scenes/world/world.tscn",
	"res://scenes/basement/basement.tscn",
	"res://scenes/boss/boss.tscn",
]

var scene: Node : set = set_scene, get = get_scene

var vp: Viewport
var rect: ColorRect

var mouse_mode: Input.MouseMode = Input.MouseMode.MOUSE_MODE_VISIBLE : get = get_mouse_mode, set = set_mouse_mode
var tw: Tween

var is_changing_scenes: bool

func _initialize() -> void:
	if Engine.is_editor_hint(): return
	
	# Workaround to avoid error messages on game launch.
	ThemeDB.get_project_theme().set_theme_item(Theme.DATA_TYPE_STYLEBOX, &"focus", &"Button", load("res://resources/styleboxes/pointer_stylebox.tres"))
	
	# Only runs when running the main scene.
	# AS OF 4.5: ["--scene", "uid://bd31f2ihbhefp", "some_var", "value"]
	#if not "uid" in OS.get_cmdline_args()[0]:
		#scene = current_scene
		#return
	
	var svc: SubViewportContainer = SubViewportContainer.new()
	svc.stretch = true
	
	svc.material = preload("res://resources/materials/main_viewport.tres")
	svc.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	svc.set_anchors_preset(Control.PRESET_FULL_RECT)
	
	vp = SubViewport.new()
	vp.audio_listener_enable_3d = true
	vp.handle_input_locally = false
	vp.physics_object_picking = true
	svc.add_child(vp, true)
	
	root.add_child.call_deferred(svc, true)
	
	if ProjectSettings.get_setting(SETTING_TRANSITION, 0.0) > 0.0:
		rect = ColorRect.new()
		
		rect.z_index = 1
		rect.color = Color(0,0,0,0)
		rect.set_anchors_preset(Control.PRESET_FULL_RECT)
		rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		rect.name = TRANSITION_RECT_NAME
		root.add_child(rect, true, Node.INTERNAL_MODE_FRONT)
	
	root.ready.connect(_on_root_ready, CONNECT_ONE_SHOT)
	
	#if OS.is_debug_build():
	root.window_input.connect(_on_root_input)

func _on_root_ready() -> void:
	scene = current_scene
	current_scene.reparent.call_deferred(vp, false)

func change_scene(node: Node) -> void:
	if is_changing_scenes:
		print("Rejecting scene transisiton to %s" % node)
		node.free()
		return
	
	is_changing_scenes = true
	
	print("CHANGING SCENE: %s => %s" % [scene, node])
	
	if tw:
		tw.kill()
	
	tw = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	
	if rect: # Transition in if rect found.
		tw.tween_property(rect, ^"color:a", 1.0, maxf(0.01, ProjectSettings[SETTING_TRANSITION]))
	
	if scene:
		if scene.get_parent() == vp:
			tw.tween_callback(scene.get_parent().remove_child.bind(scene))
		tw.tween_callback(scene.free)
	
	tw.tween_callback(set_scene.bind(node))
	tw.tween_callback(vp.add_child.bind(node))
	
	if rect:
		tw.tween_property(rect, ^"color:a", 0.0, maxf(0.01, ProjectSettings[SETTING_TRANSITION]))
	
	tw.tween_callback(set.bind(&"is_changing_scenes", false))

func change_scene_path(path: String) -> void:
	change_scene(load(path).instantiate())

func change_scene_packed(packed: PackedScene) -> void:
	change_scene(packed.instantiate())

func _on_root_input(event: InputEvent) -> void:
	if not event.is_pressed() or event.is_echo(): return
	
	# For web build...
	#Input.mouse_mode = mouse_mode 
	
	if event is InputEventKey:
		match event.keycode:
			# Jump to scene
			var kp_num when KEY_KP_0 <= kp_num and kp_num <= KEY_KP_9 and kp_num - KEY_KP_0 < DEBUG_SCENE_PATHS.size():
				change_scene(load(DEBUG_SCENE_PATHS[kp_num - KEY_KP_0]).instantiate())
			
			var num when KEY_0 <= num and num <= KEY_9 and num - KEY_0 < DEBUG_SCENE_PATHS.size():
				change_scene(load(DEBUG_SCENE_PATHS[num - KEY_0]).instantiate())
			
			KEY_EQUAL:
				Node.print_orphan_nodes()

func get_transition_rect() -> ColorRect:
	for i: int in root.get_child_count(true):
		if root.get_child(i, true) is ColorRect:
			return root.get_child(i, true)
	return null

func get_mouse_mode() -> Input.MouseMode:
	return mouse_mode

func set_mouse_mode(val: Input.MouseMode) -> void:
	mouse_mode = val
	Input.mouse_mode = val

func get_scene() -> Node:
	return scene

func set_scene(val: Node) -> void:
	assert(scene != val)
	scene = val
	scene_changed.emit()
