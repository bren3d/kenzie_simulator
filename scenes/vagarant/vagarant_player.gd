@tool
class_name VagarantPlayer extends CharacterBody3D

const SPEED = 7.5
const MAX_DAMAGE_PER_SHOT: int = 3
const DAMAGE_TEXTURE_FADE_DURATION_SEC: float = 0.3

@export var camera: Camera3D
@export var gun: Gun
@export var health_label: Label
@export var damage_texture: DamageTexture
@export var start_label: Label
@export var round_won_label: Label
@export var kill_feed: KillFeed
@export var headshot_audio_stream: AudioStreamPlayer

@export_range(0.05, 10.0, 0.05, "or_greater", "exp" ) 
var camera_sensitivity: float = 0.7

var targeting_handle: TargetingHandle
var event_handle: VagarantEventHandle

var health: int = 100: set = set_health

var input_active: bool = false

func _ready() -> void:
	if Engine.is_editor_hint(): return
	gun.shot.connect(_on_shot)
	round_won_label.modulate.a = 0.0
	start_label.modulate.a = 0.0
	damage_texture.modulate.a = 0.0
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func start() -> void:
	camera.make_current()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	input_active = true
	var tw: Tween = create_tween().set_trans(Tween.TRANS_QUART)
	tw.tween_property(start_label, ^"modulate:a", 1.0, 0.5)
	tw.tween_property(start_label, ^"modulate:a", 0.0, 2.5)

func end() -> void:
	create_tween().set_trans(Tween.TRANS_QUART).tween_property(round_won_label, ^"modulate:a", 1.0, 0.5)

func _on_combatant_dead(combatant: Combatant, killer: Node3D) -> void:
	update_kill_feed(combatant, killer)

func update_kill_feed(combatant: Combatant, killer: Node3D) -> void:
	kill_feed.update(combatant, killer)

func _on_shot() -> void:
	var target:= get_shot_target()
	if target:
		headshot_audio_stream.play()
		target.kill(self)


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint() or not input_active: return
	
	if Input.is_action_pressed(&"shoot"):
		gun.shoot()
	
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	var input_dir := Input.get_vector(&"left", &"right", &"up", &"down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

func get_shot_target() -> Combatant:
	for enemy: Combatant in targeting_handle.enemies:
		if enemy and enemy.is_shootable(self) and enemy.is_on_screen():
			return enemy
	return null

func get_display_name() -> String:
	return Global.player_name


func _unhandled_input(event: InputEvent) -> void:
	if not input_active: return
	
	if event is InputEventMouseMotion:
		rotation.y -= event.screen_relative.x / 1000 * camera_sensitivity
		camera.rotation.x = clampf(camera.rotation.x - event.screen_relative.y / 1000 * camera_sensitivity, -Player.MAX_PITCH, Player.MAX_PITCH)
	
	#if event is InputEventKey and event.is_pressed() and not event.is_echo() and event.keycode == KEY_ESCAPE:
		#Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED else Input.MOUSE_MODE_CAPTURED

func set_health(val: int) -> void:
	health = clampi(val, 1, 100)
	health_label.text = "HP: %d" % health

func damage() -> void:
	damage_texture.tick()
	var dmg: int = 0
	if health > 80:
		dmg = (randi() % 3) + 1
	elif health > 40:
		dmg = (randi() % 2) + 1
	elif health > 1:
		dmg = 1
	
	health -= dmg
