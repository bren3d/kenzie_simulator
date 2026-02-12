@tool
class_name Combatant extends CharacterBody3D

signal dead(killer: Node3D)

const SPEED: float = 7.5
const MAX_SHOT_COUNT: int = 4

const COLOR_ALLY: Color = Color.LIME_GREEN
const COLOR_ENEMY: Color = Color.ORANGE_RED

@export_placeholder("FredMustard") 
var display_name: String = ""

@export var visibility_notifier: VisibleOnScreenNotifier3D
@export var audio_player: AudioStreamPlayer3D
@export var sprite: Sprite3D
@export var flash_sprite: Sprite3D
@export var shooting_ray: RayCast3D

@export var is_ally: bool = false:
	set(val):
		is_ally = val
		if not Engine.is_editor_hint():
			set_modulate(COLOR_ALLY if is_ally else COLOR_ENEMY)

var targeting_handle: TargetingHandle
var event_handle: VagarantEventHandle

var movement_target: Node3D

var shooting_target: Node3D
var kill_target: Node3D

var is_shooting: bool = false
var is_dead: bool = false

func _ready() -> void:
	if Engine.is_editor_hint(): return
	
	flash_sprite.hide()
	is_ally = is_ally

func start() -> void:
	assert(targeting_handle)
	movement_target = targeting_handle.get_movement_target(self)
	create_tween().set_loops().tween_callback(update_movement_target).set_delay(2.0)

func end() -> void:
	pass

func update_movement_target() -> void:
	if movement_target: return
	movement_target = targeting_handle.get_movement_target(self)

func _on_combatant_dead(combatant: Combatant, killer: Node3D) -> void:
	if combatant == movement_target:
		movement_target = null
		movement_target = targeting_handle.get_movement_target(self)
	
	if combatant == shooting_target:
		shooting_target = null

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if movement_target and not shooting_target:
		var dir: Vector3 = ((movement_target.global_position - global_position)* Vector3(1.0, 0.0, 1.0)).normalized()
		velocity = dir * SPEED
	
	else:
		
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
	tw.finished.connect(_on_shoot_tween_finished, CONNECT_ONE_SHOT)


func damage_target() -> void:
	if not shooting_target is VagarantPlayer: return
	shooting_target.damage()


func kill(attacker: Node3D) -> void:
	dead.emit(attacker)
	queue_free()

func _on_shoot_tween_finished() -> void:
	is_shooting = false
	if not kill_target: return
	
	kill_target.kill(self)
	#print("%s Killed %s" % [self.get_display_name(), kill_target.get_display_name()])

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

func get_display_name() -> String:
	return display_name

func _input(event: InputEvent) -> void:
	if not event.is_pressed() or event.is_echo(): return
	
	if event is InputEventKey and event.keycode == KEY_U:
		shoot(get_shot_count())
