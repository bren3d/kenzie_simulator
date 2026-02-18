@tool
extends PlayerState

var attempting_jump: bool

func _init() -> void:
	name = &"Moving"

func enter() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	player.input_active = true
	player.input_dir = Input.get_vector(&"left", &"right", &"up", &"down")
	player.sprinting = Input.is_action_pressed(&"sprint")
	attempting_jump = false

func exit() -> void:
	player.input_active = false
	player.input_dir = Vector2.ZERO
	player.sprinting = false

func update_physics_process(delta: float) -> void:
	
	if attempting_jump and player.is_on_floor():
		# TODO Transition to Jumping state
		player.velocity.y = Player.JUMP_VELOCITY
	
	attempting_jump = false
	
	var sprint_mult: float = 1.0 + float(player.sprinting) * (Player.RUN_SPEED_MULT - 1.0)
	var direction: Vector3 = (player.transform.basis * Vector3(player.input_dir.x, 0, player.input_dir.y)).normalized() if player.input_dir else Vector3.ZERO 
	
	player.velocity.x = move_toward(player.velocity.x, direction.x * player.speed * player.speed_mult * sprint_mult, player.ACCELERATION * delta)
	player.velocity.z = move_toward(player.velocity.z, direction.z * player.speed * player.speed_mult * sprint_mult, player.ACCELERATION * delta)
	
	player.velocity += player.get_gravity() * delta * int(not player.is_on_floor())
	player.move_and_slide()

func on_unhandled_input(event: InputEvent) -> void:
	
	player.move_camera(event)
	
	if event.is_action(&"pause"):
		player.pause_menu.open()
	
	elif event.is_action_pressed(&"cough"):
		player.cough()
		
	elif event.is_action_pressed(&"jump"):
		attempting_jump = true
	
	elif event.is_action_pressed(&"interact") and player.interact_ray.can_interact():
		transition_requested.emit("Interacting")
	
	#elif event.is_action_pressed(&"flashlight"):
		#player.toggle_flashlight()
	
	elif event.is_action(&"sprint"):
		player.sprinting = event.is_pressed()
	
	elif event.is_action(&"left") or event.is_action(&"right") or event.is_action(&"up") or event.is_action(&"down"):
		player.input_dir = Input.get_vector(&"left", &"right", &"up", &"down")
	
	else:
		return
	
	get_viewport().set_input_as_handled()
