@tool
class_name VagarantEventHandle extends Node

const MAX_ROUNDS: int = 3
const NEXT_ROUND_DELAY_SEC: float = 3.5

signal round_started
signal round_ended

signal match_started
signal match_ended

signal combatant_spawned(combatant: Node3D)
signal combatant_died(combatant: Combatant, killer: Node3D)

@export var start_on_ready: bool = true
@export var targeting_handle: TargetingHandle
@export var spawners: Array[CombatantSpawner]

var round_count: int = 0

func _ready() -> void:
	for spawner: CombatantSpawner in spawners:
		spawner.spawned.connect(register_combatant)

func register_combatant(comb: Node3D) -> void:
	assert(comb is VagarantPlayer or comb is Combatant)
	
	round_started.connect(comb.start)
	round_ended.connect(comb.end)
	combatant_died.connect(comb._on_combatant_dead)
	
	if not comb is VagarantPlayer:
		comb.dead.connect(_on_combatant_dead.bind(comb))
	
	combatant_spawned.emit(comb)

func reset_round() -> void:
	free_combatants()
	spawn_combatants()

func start_round() -> void:
	round_count += 1
	round_started.emit()

func end_round() -> void:
	round_ended.emit()
	
	await get_tree().create_timer(NEXT_ROUND_DELAY_SEC).timeout
	
	if round_count < MAX_ROUNDS:
		advance_round()
	else:
		end_match()

func advance_round() -> void:
	reset_round()
	start_round()

func start_match() -> void:
	round_count = 0
	advance_round()
	match_started.emit()

func end_match() -> void:
	match_ended.emit()


func _on_combatant_dead(killer: Node3D, comb: Combatant) -> void:
	combatant_died.emit(comb, killer)

func free_combatants() -> void:
	for ally in targeting_handle.allies:
		if ally: ally.queue_free()
	
	for enemy in targeting_handle.enemies:
		if enemy: enemy.queue_free()

func spawn_combatants() -> void:
	for spawner: CombatantSpawner in spawners:
		spawner.spawn()

func _on_enemies_defeated() -> void:
	end_round()
