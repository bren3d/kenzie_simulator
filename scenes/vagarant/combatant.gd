@tool
class_name Combatant extends CharacterBody3D

signal dead

const SPEED: float = 5.0
const MAX_SHOT_COUNT: int = 4

const COLOR_ALLY: Color = Color.LIME_GREEN
const COLOR_ENEMY: Color = Color.ORANGE_RED

@export var visibility_notifier: VisibleOnScreenNotifier3D
@export var audio_player: AudioStreamPlayer3D
@export var sprite: Sprite3D
@export var flash_sprite: Sprite3D
@export var vagarant_player: VagarantPlayer
@export var targeting_handle: TargetingHandle
@export var shooting_ray: RayCast3D

@export var is_ally: bool = false:
	set(val):
		is_ally = val
		if not Engine.is_editor_hint():
			set_modulate(COLOR_ALLY if is_ally else COLOR_ENEMY)

var movement_target: Node3D:
	set(val):
		movement_target = val
		print("MOVEMENT TARGET: ", movement_target)

var shooting_target: Node3D
var is_shooting: bool = false
var is_dead: bool = false

func _ready() -> void:
	if Engine.is_editor_hint(): return
	
	flash_sprite.hide()
	is_ally = is_ally

func start(target_handle: TargetingHandle) -> void:
	targeting_handle = target_handle
	movement_target = targeting_handle.get_movement_target(self)

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	
	if movement_target and not shooting_target:
		var dir: Vector3 = ((movement_target.global_position - global_position)* Vector3(1.0, 0.0, 1.0)).normalized()
		velocity = dir * SPEED
		print(velocity)
	
	else:
		if shooting_target is VagarantPlayer and not visibility_notifier.is_on_screen():
			shooting_target = null
		
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	move_and_slide()

## Shoots in bursts of 1 - MAX_SHOT_COUNT
func shoot(shot_count: int = 1) -> void:
	is_shooting = true
	var tw: Tween = create_tween().set_loops(maxi(1, shot_count))
	tw.tween_callback(flash_sprite.show)
	tw.tween_callback(audio_player.play)
	tw.tween_callback(damage_target)
	tw.tween_interval(Gun.MUZZLE_FLASH_DURATION)
	tw.tween_callback(flash_sprite.hide)
	tw.tween_interval(Gun.SHOOT_DELAY - Gun.MUZZLE_FLASH_DURATION)
	tw.finished.connect(_on_tw_finished, CONNECT_ONE_SHOT)

func damage_target() -> void:
	if not shooting_target is VagarantPlayer: return
	shooting_target.damage()


func kill(attacker: Node3D) -> void:
	is_dead = true
	dead.emit()
	queue_free()

func _on_tw_finished() -> void:
	is_shooting = false
	if not shooting_target or shooting_target is VagarantPlayer or is_dead: return
	shooting_target.kill(self)

func is_shootable(attacker: Node3D = null) -> bool:
	shooting_ray.target_position = attacker.global_position - global_position
	shooting_ray.force_raycast_update()
	return shooting_ray.get_collider() == attacker

func is_on_screen() -> bool:
	return visibility_notifier.is_on_screen()

func set_modulate(val: Color) -> void:
	sprite.modulate = val

func get_shot_count() -> int:
	return (randi() % MAX_SHOT_COUNT) + 1

func _input(event: InputEvent) -> void:
	if not event.is_pressed() or event.is_echo(): return
	
	if event is InputEventKey and event.keycode == KEY_U:
		shoot(get_shot_count())
