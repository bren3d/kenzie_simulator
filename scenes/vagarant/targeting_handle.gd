@tool
class_name TargetingHandle extends Node

const UPDATE_SHOOT_DELAY_SEC: float = 1.0

signal enemies_defeated

var allies: Array[Node3D]
var enemies: Array[Combatant]

var update_shoot_timer: float = UPDATE_SHOOT_DELAY_SEC

func _ready() -> void:
	if Engine.is_editor_hint(): return

func register_combatant(comb: Node3D) -> void:
	assert(comb is VagarantPlayer or comb is Combatant)

	comb.targeting_handle = self
	if comb is VagarantPlayer or comb.is_ally:
		allies.push_back(comb)
	else:
		enemies.push_back(comb)

func update_shooting() -> void:
	for enemy: Combatant in enemies:
		if not enemy or enemy.shooting_target is Combatant: continue
		#enemy.shooting_target = null
		for ally: Node3D in allies:
			if not ally or not enemy.is_shootable(ally): continue
			
			if enemy.is_dead:
				enemy.kill(ally)
				continue
			elif ally is Combatant and ally.is_dead:
				ally.kill(enemy)
				continue
				
			enemy.shooting_target = ally
			enemy.shoot(enemy.get_shot_count())
			
			if ally is Combatant:
				ally.shooting_target = enemy
				ally.shoot(ally.get_shot_count())
				var loser: Combatant = get_shootout_loser(enemy, ally)
				
				if loser == ally:
					enemy.kill_target = ally
				else:
					ally.kill_target = enemy
				
				loser.is_dead = true
				
			break

func _on_combatant_dead(combatant: Combatant, killer: Node3D) -> void:
	if combatant in allies:
		allies.erase(combatant)
	else:
		enemies.erase(combatant)
	
	if enemies.is_empty():
		enemies_defeated.emit()

func get_shootout_loser(shooter_a: Combatant, shooter_b: Combatant) -> Combatant:
	return shooter_a if (randi() % 2) > 0 else shooter_b

func get_movement_target(comb: Combatant) -> Node3D:
	var target_pool: Array[Node3D] = []
	target_pool.assign(enemies if comb.is_ally else allies)
	var closest_target: Node3D
	var closest_distance_squared: float = 0.0
	for node: Node3D in target_pool:
		if not node: continue
		var target_distance_squared: float = comb.global_position.distance_squared_to(node.global_position)
		if not closest_target or closest_distance_squared > target_distance_squared:
			closest_target = node
			closest_distance_squared = target_distance_squared
	
	return closest_target

func get_combatants() -> Array[Node3D]:
	var combatants: Array[Node3D]
	for ally in allies:
		if is_instance_valid(ally): combatants.push_back(ally)
	for enemy in enemies:
		if is_instance_valid(enemy): combatants.push_back(enemy)
	return combatants

func clear_combatants() -> void:
	allies.clear()
	enemies.clear()
	update_shoot_timer = UPDATE_SHOOT_DELAY_SEC

func _process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	update_shoot_timer -= delta
	if update_shoot_timer <= 0.0:
		update_shoot_timer += UPDATE_SHOOT_DELAY_SEC
		update_shooting()
