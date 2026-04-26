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
	
	var start_callable: Callable = Callable(comb, &"start")
	var end_callable: Callable = Callable(comb, &"end")
	var combatant_dead_callable: Callable = Callable(comb, &"_on_combatant_dead")

	if not round_started.is_connected(start_callable):
		round_started.connect(start_callable)
	if not round_ended.is_connected(end_callable):
		round_ended.connect(end_callable)
	if not combatant_died.is_connected(combatant_dead_callable):
		combatant_died.connect(combatant_dead_callable)
	
	if comb is Combatant:
		var combatant: Combatant = comb
		var dead_callable: Callable = _on_combatant_dead.bind(combatant)
		if not combatant.dead.is_connected(dead_callable):
			combatant.dead.connect(dead_callable)
	
	combatant_spawned.emit(comb)

func unregister_combatant(comb: Node3D) -> void:
	if not is_instance_valid(comb): return

	var start_callable: Callable = Callable(comb, &"start")
	var end_callable: Callable = Callable(comb, &"end")
	var combatant_dead_callable: Callable = Callable(comb, &"_on_combatant_dead")

	if round_started.is_connected(start_callable):
		round_started.disconnect(start_callable)
	if round_ended.is_connected(end_callable):
		round_ended.disconnect(end_callable)
	if combatant_died.is_connected(combatant_dead_callable):
		combatant_died.disconnect(combatant_dead_callable)

	if comb is Combatant:
		var combatant: Combatant = comb
		var dead_callable: Callable = _on_combatant_dead.bind(combatant)
		if combatant.dead.is_connected(dead_callable):
			combatant.dead.disconnect(dead_callable)

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
	for combatant: Node3D in targeting_handle.get_combatants():
		if not is_instance_valid(combatant): continue
		unregister_combatant(combatant)
		combatant.queue_free()
	
	targeting_handle.clear_combatants()

func spawn_combatants() -> void:
	for spawner: CombatantSpawner in spawners:
		spawner.spawn()

func _on_enemies_defeated() -> void:
	end_round()
