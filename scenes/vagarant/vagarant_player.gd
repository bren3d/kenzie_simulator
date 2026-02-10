@tool
class_name VagarantPlayer extends CharacterBody3D

const SPEED = 5.0
const MAX_DAMAGE_PER_SHOT: int = 3
const DAMAGE_TEXTURE_FADE_DURATION_SEC: float = 0.3

@export var camera: Camera3D
@export var gun: Gun
@export var health_label: Label
@export var damage_texture: DamageTexture
@export var targeting_handle: TargetingHandle

@export_range(0.05, 10.0, 0.05, "or_greater", "exp" ) 
var camera_sensitivity: float = 0.7

var health: int = 100: set = set_health

var input_active: bool = false

func _ready() -> void:
	if Engine.is_editor_hint(): return
	damage_texture.modulate.a = 0.0
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func damage() -> void:
	var dmg: int = (randi() % 3) + 1
	damage_texture.tick()
	health -= dmg

func start(target_handle: TargetingHandle) -> void:
	targeting_handle = target_handle
	input_active = true

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	
	if Input.is_action_pressed(&"shoot"):
		gun.shoot()
		var target:= get_shot_target()
		if target and not target.is_dead:
			target.kill(self)
	
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

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotation.y -= event.screen_relative.x / 1000 * camera_sensitivity
		camera.rotation.x = clampf(camera.rotation.x - event.screen_relative.y / 1000 * camera_sensitivity, -Player.MAX_PITCH, Player.MAX_PITCH)
	
	if event is InputEventKey and event.is_pressed() and not event.is_echo() and event.keycode == KEY_ESCAPE:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED else Input.MOUSE_MODE_CAPTURED

func set_health(val: int) -> void:
	health = clampi(val, 59, 100)
	health_label.text = "HP: %d" % health
	
